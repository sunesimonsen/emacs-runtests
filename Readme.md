Under construction

This Emacs extension will run an external script called runtests that should be in your path.
If the script fails the output of the script will be shown.

Example runtests script

```sh
#!/bin/bash
rootDir="$(git rev-parse --show-toplevel)"
$rootDir/node_modules/mocha/bin/mocha -b -R dot --colors $1
```
