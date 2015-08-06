# runtests.el

This Emacs extension will run an external script called `runtests` that should
be in your path. If the script fails the output of the script will be shown with
ansi colors.

The idea is that we offload all the nitty gritty details of executing the tests
for the current buffer to a shell script. You bind the `runtests` command to a
key that will run the tests for the current buffer.

```sh
#!/bin/bash
rootDir="$(git rev-parse --show-toplevel)"
$rootDir/node_modules/mocha/bin/mocha -b -R dot --colors $1
```
You can customize the command being executed when calling `runtests` by
customizing the `runtests` group.

To set the `runtests-command` for a particular mode in a given project, you can use
[Per-Directory Local Variables](http://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html).

# License

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see http://www.gnu.org/licenses/.
