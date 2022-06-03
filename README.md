# Loco.sh

***Loco.sh*** is a **lo**cal **co**nfiguration manager. It can install any package *(apt, ppas, brew, snap, pip...)*, manage dotfiles, terminal style, fonts, and perform custom configuration tasks. ***Loco.sh*** is based on *profiles* that centralizes configurations for a specific user or user type, accross one or more operating systems, and *actions* which run workflows on top of the *profiles*.

***Loco.sh*** can be useful to :

- **system administrators**, who need to manage their users profiles in a single place
- **security consultants**, to deal with a variety of identities and security access
- **developers**, who need to manage various environments and machines, with the same look and feel
- **regular users**, who can easily manage their configuration files

***Loco.sh*** comes with 5 example profiles :

- **default** : default example for an user profile, does mostly nothing but installing ```tree``` to showcase the basics and *profile* folder structure
- **loco-vim** : provides a fully configured ```vim``` (removes nvim if installed) ; supports MacOSx and Ubuntu
- **loco-zsh-p10k** : a fully configured ```zsh``` with ```p10K``` ; supports MacOSx and Ubuntu
- **loco-term** : a custom themed terminal ; supports Ubuntuw
- **loco-vim-zsh-p10k-term** : all examples made into one profile
<!-- - **loco-nvim** : same as *loco-shell* with nvim ; supports MacOSx and Ubuntu -->
<!-- - **loco-webdev** : a more complete and opiniated example, comes with extra packages ; supports Ubuntu and partially MacOSx -->

**WARNING** : *use this script at your own risk as it will deal with your system configuration.*

## Installation

### One-liner

To install and execute ```loco``` :
```bash
bash <(wget -qO- https://raw.githubusercontent.com/t0pd4wn/loco.sh/gh-main/src/utils/loco_installation.sh)
```

You can pass options like this :
```bash
bash <(wget -qO- https://raw.githubusercontent.com/t0pd4wn/loco.sh/gh-main/src/utils/loco_installation.sh) [options]
```

For example, you can launch a verbose installation like this :
```bash
bash <(wget -qO- https://raw.githubusercontent.com/t0pd4wn/loco.sh/gh-main/src/utils/loco_installation.sh) -a install -V
```

Once installed, you can simply interact with loco like this : 
```bash
cd ~/loco-dist
./loco [options]
```

### Manually

```bash
#clone repo
git clone [repository]

#navigate to repo
cd [repository]

#execute interactive script
./loco [options]
```

***Forking this repository*** is advised as you may want to save changes you will make to *profiles* (or contribute them as PRs). To understand further how to do so, see [make loco your own](#make-loco-your-own).

## Profiles

*Profiles* are made of a YAML file, dotfiles, scripts and other assets.

- folder structure : ```./profiles/``` 

```bash
.
└── profiles
	└── [profile]
		├── profile.yaml # profile description (needed)
		├── custom.sh # custom functions (optional)
		├── assets #stores specific files (optional)
		│	├── fonts # fonts in this folder will be installed (optional)
		│	└── terminal.conf # user terminal configuration (optional, ubuntu only)
		└── dotfiles # dotfiles in this folder will be symlinked or hard copied (optional)

```

- YAML schema : ```./profiles/[profile]/profile.yaml``` 

```yaml
styles:
  fonts :
    - [font url]
packages :
  generic :
    npm :
      - [package name]
    pip3 :
      - [package name]
  macos :
    brew :
      - [package name]
  ubuntu :
    ppa :
      - [ppa address] # ppa must be declared before apt
    apt :
      - [package or ppa-package name]
    snap :
      - [package name]
```

- custom functions pattern : ```./profiles/[profile]/custom.sh``` 

```bash
#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

# function name pattern
[action]_[os_type]_custom_[entry/exit/last](){
    # insert commands below
}

# example for a macOS installation entry function 
install_macos_custom_entry(){
    # insert commands below
}

# example for a Ubuntu removal exit function 
remove_ubuntu_custom_exit(){
    # insert commands below
}
```

Note : in ```bash``` empty functions are not allowed and will forbid sourcing the ```custom.sh``` script.

### Add a profile

To create a new *profile*, simply duplicate one available in ```/profiles/```, and start editing it as you please.

*Profiles* foldername can be set through the ```-p``` option.

Note : be careful about adding ```git submodules``` into your profiles as you may be in difficulty for retrieving them. See [this open issue.](https://github.com/dear-github/dear-github/issues/214) for various solutions, including Github actions.

## Actions

*Actions* are scripts applied to the *profiles*.

```bash
.
└── src
	└── actions #stores actions scripts
		├── install.sh # install packages and dotfiles, based on a profile
		└── remove.sh  # remove packages and dotfiles, based on an installed instance
```

### Add an action

To create an action, simply duplicate one available in ```/src/actions/``` and start editing it as you please.

*Actions* can be set through the ```-a``` option.

## Instances

*Instances* store the backups for each loco installation. They are later used to restore the original $USER dotfiles. Note that only dotfiles installed by a *profile* are backed up. This helps to keep a mix of *profile* managed and $USER managed dotfiles.

```bash
.
└── instances
	└── [username]-[profile]-[YYYY-MM-DD_HH-MM-SS]
		└── dotfiles-backup #holds the original user dotfiles
```

### Manage instances

*Instances* are created automatically when an ```install``` *action* is performed. They are removed automatically when a ```remove``` *action* is performed.

*Instances* foldername can be set through the ```-i``` option.

## Script options

| Name | Command | Description |  Type |  Options |  Default |
| ------ | ------ | ------ | ------ | ------ | ------ |
| ACTION | a | Define the loco action | string | install, remove | - |
| PROFILE | p | Define the loco profile | string | default, loco-vim, loco-nvim, loco-full | - |
| CURRENT_USER | u | Define the current user name (default : \`$USER\`) | string | [user defined] | $USER |
| PROFILES_DIR | t | Define path for profiles directories | string |  [user defined] | "profiles" |
| INSTANCES_DIR | i | Define path for profiles instances | string | [user defined] | "instances" |
| CONFIG_PATH | c | Define path to the configuration file |  string | [user defined] | "./src/loco.conf" |
| DETACHED | d | Define if dotfiles are symbolically linked from repo or from  | boolean | true/false | false |
| WATERMARK | w | Define if a loco watermark is set (needed for remove)| boolean | true/false | true |
| VERBOSE | V | Verbose mode | flag | - | - |
| YES | Y | Automate the yes answer (the few left) | flag | - | - |
| ROOT | R | Remove the sudo prompt (experimental) | flag | - | - |
| HELP | h | Display options and exit | flag | - | - |
| VERSION | v | Print Version and exit | flag | - | - |

### Define static options

Options can be set directly into ```/src/loco.conf```.

```bash
.
└── src
	└── loco.conf #stores static options
```

## Other

### Make ```loco``` your own
<<<<<<< HEAD
The first point you need to keep in mind is security. SSH and GPG keys shall not be shared over the public internet, as should not servers configurations. To make ```loco``` your own, you first need to fork it over a private repository, or your own ```git``` server. Then :
- for Gitlab.com or private Gitlab instances
1. Retrieve your API [private token]
2. Retrieve the [project ID]
3. Update ```./src/utils/loco_installation.sh``` with your information :
```bash
# modify below with your infos #
local branch_name="gh-main"
local git_server="https://gitlab.com"
local project_ID="1234"
local secret_key="ABC-123"
# # # # end of modifications
```
4. modify function call in ```./src/utils/loco_installation.sh``` from 
  ```bash
  retrieve_public_archive "$@"
  ``` 
  to 
  ```bash
  retrieve_private_archive "$@"
  ```
5. Optional : [build a release](#build-a-release).
6. Git add, commit and push to your ```gitlab``` server.
7. You can now install ```loco``` with this url pattern :
```bash
bash <(wget  --header="PRIVATE-TOKEN: [private token]" -qO- https://[gitlab server]/api/v4/projects/[project ID]/repository/files/src%2Futils%2Floco_installation.sh/raw?ref=gh-main)
The first point you need to keep in mind is security. SSH or GPG keys for example are quite unwelcomed on the public internet, as could be servers configurations. To make ```loco``` your own, you first need to fork it over a private repository. Then :
- for Gitlab.com
1. Retrieve your API [private token]
2. Retrieve the [project ID]
3. Update ```./src/utils/loco_installation.sh``` with your private repo url
4. You can now install loco with this url :
```bash
bash <(wget  --header="PRIVATE-TOKEN: [private token]" -qO- https://gitlab.com/api/v4/projects/[project ID]/repository/files/src%2Futils%2Floco_installation.sh/raw?ref=gh-main)
```

### Build a release
As it is complicated to archive correctly ```git sub-modules``` in *profiles*, ```loco``` provides a release archive in ```/dist/```. To update it, launch ```./src/utils/loco_build_release.sh```.

## Backlog
- enforce best practices
- first/last/after
- add actions : upgrade, init, save
- add profiles : devops, data-scientist...
- remove action shall not rely on the base profile
- improve bash modules structure
- improve backup workflow
- absolute path variable ?
- display prompts options as table rows
- add term styles
- write architecture documentation
- run_as_user ?
- more YAML logic (parse .yaml files)
- Ghost mode leaving no assets prior to action
- install multiple profiles for one user (update watermark)
- document retrieving profiles form private source

## Thanks

All of you, ***Eses*** !

Made in bash.