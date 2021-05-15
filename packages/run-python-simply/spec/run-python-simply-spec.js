'use babel';

import Runner from '../lib/run-python-simply';

// Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
//
// To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
// or `fdescribe`). Remove the `f` to unfocus the block.

describe('Run python simply', () => {
  let workspaceElement, activationPromise;
  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace);
    activationPromise = atom.packages.activatePackage('run-python-simply');
  });

  describe('when trigger the runner', () => {
    it('print the log', () => {
      // This is an activation event, triggering it will cause the package to be
      // activated.
      atom.commands.dispatch(workspaceElement, 'rum-python-simply:toggle');

      // waitsForPromise(() => {
      //   return activationPromise;
      // });


    });

  });
});
