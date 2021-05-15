# @atxm/developer-console

[![npm](https://flat.badgen.net/npm/license/@atxm/developer-console)](https://www.npmjs.org/package/@atxm/developer-console)
[![npm](https://flat.badgen.net/npm/v/@atxm/developer-console)](https://www.npmjs.org/package/@atxm/developer-console)
[![CircleCI](https://flat.badgen.net/circleci/github/a-t-x-m/developer-console)](https://circleci.com/gh/a-t-x-m/developer-console)
[![David](https://flat.badgen.net/david/dep/a-t-x-m/developer-console)](https://david-dm.org/a-t-x-m/developer-console)

Wrapper to limit console output to Atom in Developer Mode

## Installation

`npm install @atxm/developer-console -S`

## Usage

**Examples**:

```js
// JavaScript
import DeveloperConsole from '@atxm/developer-console';

const console = new DeveloperConsole({
    name: 'my-module',
    backgroundColor: 'slategrey',
});

console.log('All set up!');
```

## License

This work is dual-licensed under [The MIT License](https://opensource.org/licenses/MIT) and the [GNU General Public License, version 2.0](https://opensource.org/licenses/GPL-2.0)