request = require 'request-promise-native'
log = require './log'

class GitlabStatus
    constructor: (@view, @timeout=null, @projects={}, @pending=[], @jobs={}) ->
        @token = atom.config.get('gitlab-integration.token')
        @period = atom.config.get('gitlab-integration.period')
        @unsecureSsl = atom.config.get('gitlab-integration.unsecureSsl')
        @updating = {}
        @watchTimeout = null
        @protocol = 'https'

    fetch: (host, q, paging=false) ->
        log " -> fetch '#{q}' from '#{host}'"
        @get("#{@protocol}://#{host}/api/v4/#{q}").then((res) =>
            log " <- ", res
            if res.headers['x-next-page']
                if paging
                    log " -> retrieving #{res.headers['x-total-pages']} pages"
                    Promise.all(
                        [res.body].concat(
                            new Array(
                                parseInt(res.headers['x-total-pages']) - 1,
                            ).fill(0).map(
                                (dum, i) =>
                                    log " -> page #{i + 2}"
                                    @get(
                                        "#{@protocol}://#{host}/api/v4/#{q}" +
                                        (if q.includes('?') then '&' else '?') +
                                        "per_page=" + res.headers['x-per-page'] +
                                        "&page=#{i+2}"
                                    ).then((page) =>
                                        log "     <- page #{i + 2}", page
                                        page.body
                                    ).catch((error) =>
                                        console.error "cannot fetch page #{i + 2}", error
                                        Promise.resolve([])
                                    )
                            )
                        )
                    ).then((all) =>
                        Promise.resolve(all.reduce(
                            (all, one) =>
                                all.concat(one)
                            , [])
                        )
                    )
                else
                    log " -> ignoring paged output for #{q}"
                    res.body
            else
                res.body
        )

    get: (url) =>
        request({
            method: 'GET',
            uri: url,
            headers: {
                "PRIVATE-TOKEN": @token,
            },
            resolveWithFullResponse: true,
            json: true,
            agentOptions: {
                rejectUnauthorized: @unsecureSsl is false,
            }
        }).catch((error) =>
            if url.startsWith('https')
                console.error "cannot perform request #{url}, retrying using http", error
                @get(url.replace('https', 'http')).then((result) =>
                    @protocol = 'http'
                    Promise.resolve(result)
                ).catch((error) => Promise.reject(error))
            else
                Promise.reject(error)
        )

    watch: (host, projectPath, repos) ->
        projectPath = projectPath.toLowerCase()
        if not @projects[projectPath]? and not @updating[projectPath]?
            @updating[projectPath] = false
            @view.loading projectPath, "loading project..."
            @fetch(host, "projects?membership=yes", true).then(
                (projects) =>
                    projects = projects.map(
                        (project) =>
                            project.path_with_namespace = project.path_with_namespace.toLowerCase()
                            project
                    )
                    log "received projects from #{host}", projects
                    if projects?
                        project = projects.filter(
                            (project) =>
                                project.path_with_namespace is projectPath
                        )[0]
                        if project?
                            @projects[projectPath] = { host, project, repos }
                            @update()
                        else
                            @view.unknown(projectPath)
                    else
                        @view.unknown(projectPath)
            ).catch((error) =>
                @updating[projectPath] = undefined
                console.error "cannot fetch projects from #{host}", error
                @view.unknown(projectPath)
            )

    schedule: ->
        if @period?
            @timeout = setTimeout @update.bind(@), @period

    update: ->
        @pending = Object.keys(@projects).slice()
        @updatePipelines()

    updatePipelines: ->
        Object.keys(@projects).map(
            (projectPath) =>
                { host, project, repos } = @projects[projectPath]
                if project? and project.id? and not @updating[projectPath]
                    @updating[projectPath] = true
                    try
                        ref = repos?.getShortHead?()
                    catch error
                        console.error "cannot get project #{projectPath} ref", error
                        delete @projects[projectPath]
                        return Promise.resolve(@endUpdate(projectPath))
                    if ref?
                        log "project #{project} ref is #{ref}"
                        ref = "?ref=#{ref}"
                    else
                        ref = ""
                    if not @jobs[projectPath]?
                        @view.loading(projectPath, "loading pipelines...")
                    @fetch(host, "projects/#{project.id}/pipelines#{ref}").then(
                        (pipelines) =>
                            log "received pipelines from #{host}/#{project.id}", pipelines
                            if pipelines.length > 0
                                @updateJobs(host, project, pipelines[0])
                            else
                                @onJobs(project, [])
                    ).catch((error) =>
                        console.error "cannot fetch pipelines for project #{projectPath}", error
                        Promise.resolve(@endUpdate(projectPath))
                    )
        )

    endUpdate: (project) ->
        log "project #{project} update end"
        @updating[project] = false
        @pending = @pending.filter((pending) => pending isnt project)
        if @pending.length is 0
            @view.onStagesUpdate(@jobs)
            @schedule()
        @jobs[project]

    updateJobs: (host, project, pipeline) ->
        if not @jobs[project.path_with_namespace]?
            @view.loading(project.path_with_namespace, "loading jobs...")
        @fetch(host, "projects/#{project.id}/" + "pipelines/#{pipeline.id}/jobs", true)
        .then((jobs) =>
            log "received jobs from #{host}/#{project.id}/#{pipeline.id}", jobs
            if jobs.length is 0
                @onJobs(project, [
                    name: pipeline.name
                    status: pipeline.status
                    jobs: []
                ])
            else
                @onJobs(project, jobs.sort((a, b) -> a.id - b.id).reduce(
                    (stages, job) ->
                        stage = stages.find(
                            (stage) -> stage.name is job.stage
                        )
                        if not stage?
                            stage =
                                name: job.stage
                                status: 'success'
                                jobs: []
                            stages = stages.concat([stage])
                        stage.jobs = stage.jobs.concat([job])
                        return stages
                , []).map((stage) ->
                    Object.assign(stage, {
                        status: stage.jobs
                            .sort((a, b) -> b.id - a.id)
                            .reduce((status, job) ->
                                switch
                                    when job.status is 'pending' then 'pending'
                                    when job.status is 'created' then 'created'
                                    when job.status is 'canceled' then 'canceled'
                                    when job.status is 'running' then 'running'
                                    when job.status is 'skipped' then 'skipped'
                                    when job.status is 'failed' and
                                        status is 'success' then 'failed'
                                    else status
                            , 'success')
                    })
                ))
        ).catch((error) =>
            console.error "cannot fetch jobs for pipeline ##{pipeline.id} of project #{project.path_with_namespace}", error
            Promise.resolve(@endUpdate(project.path_with_namespace))
        )

    onJobs: (project, stages) ->
        @jobs[project.path_with_namespace] = stages.slice()
        @endUpdate(project.path_with_namespace)
        Promise.resolve(stages)

    stop: ->
        if @timeout?
            clearTimeout @timeout
        if @watchTimeout?
            clearTimeout @watchTimeout
        @view.hide()

    deactivate: ->
        @stop()

module.exports = GitlabStatus
