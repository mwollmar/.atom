# run-python-simply package
[![GitHub issues](https://img.shields.io/github/issues/techstay/run-python-simply.svg?style=plastic)](https://github.com/techstay/run-python-simply/issues)
[![GitHub stars](https://img.shields.io/github/stars/techstay/run-python-simply.svg?style=plastic)](https://github.com/techstay/run-python-simply/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/techstay/run-python-simply.svg?style=plastic)](https://github.com/techstay/run-python-simply/network)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=plastic)](https://raw.githubusercontent.com/techstay/run-python-simply/master/LICENSE.md)

Run a python file in cmd or Powershell or other Linux terminals.

![screenshot](https://raw.githubusercontent.com/techstay/run-python-simply/master/shot.PNG)

## Prerequisite

- Python 3 in `PATH`


## Usage

1. Open a `.py` file.
2. Press `F5` to run.


**It will save the file in current editor immediately without a confirmation, be aware.**

## Features

- cmd or Powershell
  - Two options for you, cmd and powershell. Choose one you like!
- CodeBlocks debug console style
  - Show return value and execution time
    - It is a rough time based on real time rather than CPU kernel time or CPU user time
- other Linux terminals(gnome-terminal etc.)

## Config
The commands use `{file}` as a placeholder for the file to run. I redesign the commands format to support linux systems in the future. Now Windows cmd and powershell are available.

|terminal|config|
|----|----|
|cmd|start cmd /c python {file}|
|powershell|start powershell -Command python {file}|
|gnome-terminal|gnome-terminal -x python3 {file}|

## Thanks

Thanks to [atom-python-run](https://github.com/foreshadow/atom-python-run), I learned a lot from it.
