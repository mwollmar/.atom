'use babel';

import {
  CompositeDisposable
} from 'atom';
import {
  parse,
  sep
} from 'path';
import {
  spawn
} from 'child_process';

export default {
  subscriptions: null,

  activate(state) {
    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'run-python-simply:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.subscriptions.dispose();
  },

  serialize() {
    return {};
  },

  toggle() {
    let editor = atom.workspace.getActiveTextEditor();
    if (editor) {
      let filePath = editor.getBuffer().getPath();
      if (filePath) {
        let fileInfo = parse(filePath);
        if (fileInfo.ext != '.py') {
          atom.notifications.addWarning("Current file is not a python source file");
        } else {
          editor.save()
            .then((success) => {
              let file = fileInfo.base;
              // set file path as cwd
              let dir = fileInfo.dir;
              this.run(dir, file);
            })
            .catch((error) => {
              atom.notifications.addError(`Save file failed: ${error}`);
            });
        }

      } else {
        atom.notifications.addInfo("No source file opened");
      }
    }

  },

  run(cwd, file) {
    let commandConfig = atom.config.get('run-python-simply.command').replace('{file}', `${__dirname}${sep}exec.py ${cwd} ${file}`);
    let firstSpaceIndex = commandConfig.search(' ');
    let command = commandConfig.substr(0, firstSpaceIndex);
    let args = commandConfig.substr(firstSpaceIndex + 1).split(' ');
    let process = spawn(command, args, {
      shell: true
    });
    process.unref();
  },

  config: {
    command: {
      title: 'Command',
      description: `The command to execute. For more info, see the [README](https://github.com/techstay/run-python-simply/blob/master/README.md#config)`,
      type: 'string',
      default: 'start cmd /c python {file}'
    },
  }

};
