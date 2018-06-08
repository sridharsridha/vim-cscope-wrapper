# vim-cscope-wrapper
A cscope wrapper for vim (Supports version > 7.0).

# Desciption
Plugin to generate and load cscope database.

# Installation
Kindly use any of your prefered plugin manager to install this

For vim-plug
```
  Plug 'sridharsridha/vim-cscope-wrapper'
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


