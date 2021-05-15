# atom-read-manifest

[![npm](https://flat.badgen.net/npm/license/atom-read-manifest)](https://www.npmjs.org/package/atom-read-manifest)
[![npm](https://flat.badgen.net/npm/v/atom-read-manifest)](https://www.npmjs.org/package/atom-read-manifest)
[![CircleCI](https://flat.badgen.net/circleci/github/idleberg/node-atom-read-manifest)](https://circleci.com/gh/idleberg/node-atom-read-manifest)
[![David](https://flat.badgen.net/david/dep/idleberg/node-atom-read-manifest)](https://david-dm.org/idleberg/node-atom-read-manifest)

Read the manifest (`package.json`) of any installed Atom package

## Installation

`npm install atom-read-manifest -S`

## Usage

`readManifest(packageID?: string)` / `readManifestSync(packageID?: string)`

You can omit the package ID to retrieve the manifest of the package in use

**Example**:

```js
const { readManifest, readManifestSync } = require('atom-read-manifest');

// Unique package identifier
const packageID = 'teletype';

// Asynchronous
(async () => {
    const manifest = await readManifest(packageID);
    console.log(manifest);
})();

// Synchronous
const manifest = readManifestSync(packageID);
console.log(manifest);
```

## Related

- [vscode-read-manifest](https://www.npmjs.com/package/vscode-read-manifest)

## License

This work is licensed under [The MIT License](https://opensource.org/licenses/MIT)
