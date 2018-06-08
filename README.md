# vim-cscope-wrapper
A cscope wrapper for vim in Unix/Linux/MacOSX

# Requirements
* ctags
* cscope

Kindly install ctags and cscope for your platform and add it to your
env PATH variable

Should work will any vim version.

# Installation
Kindly use any of your prefered plugin manager to install this

For vim-plug
```
  Plug 'sridharsridha/vim-cscope-wrapper'
```

Manual Install
Take a clone of the repro directly to `~/.vim/` folder
```
git clone https://github.com/sridharsridha/vim-cscope-wrapper.git
~/.vim/
```

# Usage
Use below commands to search cscope database in current or in parent
directories and load it. If database is already loaded update the database and lot it again. If not cscope database if found then prompts for building the cscope database.
```
:CscopeSetup
```
For autoloading cscope database from any of the parent directory use
below comamnd
```
:CscopeAutoLoad
```
For Purging all the cscope connection
```
:CscopePurge
```


