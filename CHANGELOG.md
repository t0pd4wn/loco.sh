# Changelog

All notable changes to ```loco.sh``` will be documented in this file.

## [Unreleased]

### Added
- ```install_sys``` action
- system paths support for ```-B``` background option
- backgrounds for project review, cybersec, gaming, shopping...
- ```start-vpn``` and ```full-yaml``` profiles
- openvpn startup function

### Changed

- ```update``` and ```remove``` actions behaviors; ```update``` will now merge profiles, including dotfiles, into existing one(s), and ```remove``` will play every profiles exit functions

## [0.8] - 2023-04-23

Improved modularity and yaml based description.

### Added

- full yaml support for profiles; profiles can be described through a single yaml file
- instance watermark yaml now holds all ```loco.sh``` information
- multiple profiles installation support

### Changed

- /src/ folders structure; more precise separation 1.of assets and code, 2. of bash core modules and ```loco``` ones.

### Removed

- ```.shell_history``` as the behavior between bash and zsh was weird 


## [0.7] - 2022-06-19

The first bugless version for ubuntu and macos.

### Added

- macos ```full``` profile support

### Fixed

- errors while installing .vimrc

## [0.6] - 2022-06-03

Update action and background behaviors.

### Added

- ```update``` action
- background prompt
- startup functions

### Fixed

- background url download

### Changed

- license to GPL-V3

## [0.5] - 2022-06-03

Terminal styles and prompts.

### Added

- configurable terminal styles
- themes prompt

### Fixed

- styles related bugs
- installation behavior


## [0.3] - 2022-06-03

Introducing remote installation means.

### Added

- remote and private installation

### fixed

- styles related bugs
- installation behavior

## [0.2] - 2022-04-18

The initial commited version.

### Added

- main ```loco.sh``` principles
- ```install``` and ```remove``` actions
- macos and ubuntu support

This changelog is inspired by the [keep a changelog](https://github.com/olivierlacan/keep-a-changelog/) project.