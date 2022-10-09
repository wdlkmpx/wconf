
# WCONF

`configure` and helper scripts + sample Makefiles

With some care and dedication, this can be used for new projects
and to replace some autotools projects

cross-compilation works pretty much the same

`./configure --help` produces the same output as the autoconf `configure`

`--enable-feature` and `--disable-feature` are also implemented

The `w_conf` directory contains several scripts, you can pick the ones you want

see `configure.project` for examples of how to do things

Files needed for projects

- `configure`
- `configure.project` = configure.ac, this is sourced by `configure`
- `Makefile`
- `w_conf/00_standard_infile.sh` for files.in
- `w_conf/..` only the features you need, see `configure.project`
- `po/` the whole directory + `w_conf/gettext`
- `src/ data/ ..` these are sample makefiles
- etc

The `Makefile.*gen` script can be used to automate some tasks

See `.gitignore` for files to be ignored by a CVS

## KNOWN PROBLEMS

- the script can't determine invalid --parameters, because a module or a sourced
script might process it later

