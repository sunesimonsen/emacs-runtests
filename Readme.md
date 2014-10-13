Under construction

This Emacs extension will run an external script called runtests that should be in your path.
If the output contains the word failing it will show the output in a buffer.

Example runtests script

```sh
#!/bin/bash
rootDir="$(git rev-parse --show-toplevel)"
$rootDir/node_modules/mocha/bin/mocha -b -R dot --colors $1
```
