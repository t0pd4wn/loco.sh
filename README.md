# Loco.sh

***Loco.sh*** is a **lo**cal **co**nfiguration manager. It can install any package *(apt, ppas, brew, snap, pip...)*, manage dotfiles, terminal styles, fonts, backgrounds, overlays, and perform custom pre and post script configuration tasks.

<img alt="Loco.sh Ubuntu demo" src="dist/loco_demo_0.7_Ubuntu.gif" width="1080">

***Loco.sh*** can be useful to:

- **regular users**, who can easily manage their desktop style
- **developers**, who need to manage various environments and machines, with the same look and feel
- **system administrators**, who need to manage their users profiles in a single place
- **security consultants**, to deal with a variety of identities and security access

***Loco.sh*** comes with 5 example profiles :

- **default**: is a default example, it does mostly nothing but installing ```tree``` to showcase the basics of a *profile* folder structure
- **base-full**: all *profiles* made into one, with ```vim```, ```zsh```  and ```p10K```
- **base-vim-only**: fully configured ```vim```
- **base-shell-only**: fully configured ```zsh``` with ```p10K```
- **base-style-only**: custom themed terminal and OS (dock, background)
<!-- - **loco-nvim**: same as *loco-shell* with nvim ; supports MacOSx and Ubuntu -->
<!-- - **loco-webdev**: a more complete and opiniated example, comes with extra packages ; supports Ubuntu and partially MacOSx -->

**WARNING**: *use this script at your own risk as it will deal with your system configuration.*

## Installation

### One-liner

To install and execute ```loco```:

#### All systems (Ubuntu, macOS)
```bash
bash <(echo https://bit.ly/3lfqopL|(read l; wget -qO- $l 2>/dev/null || curl -L $l));
```

##### Options
You can pass options like this:
```bash
bash <(echo https://bit.ly/3lfqopL|(read l; wget -qO- $l 2>/dev/null || curl -L $l)) [options];
```

For example, you can launch an interactive session with a custom background like this:
```bash
bash <(echo https://bit.ly/3lfqopL|(read l; wget -qO- $l 2>/dev/null || curl -L $l)) -a install -B "[image url]";
```

Or go ***loco*** and install directly a profile with the ```-Y``` flag on :
```bash
bash <(echo https://bit.ly/3lfqopL|(read l; wget -qO- $l 2>/dev/null || curl -L $l)) -Ya install -p base-full; exit
```

Once installed, you can simply interact with ```loco``` like this: 
```bash
cd ~/loco-dist
./loco [options]
```

### Manually

```bash
#clone repo
git clone [repository]

#navigate to repo
cd loco.sh

#execute interactive script
./loco [options]
```

***Forking this repository*** is advised as you may want to save changes you will make to *profiles* (or contribute them as PRs). To understand further how to do so, see [make loco your own](#make-loco-your-own).

## Profiles

***Loco.sh*** is based on *profiles* that centralizes configurations for a specific user or user type, accross one or more operating systems, and *actions* which run workflows on top of these *profiles*.

*Profiles* are made of a YAML file, dotfiles, scripts and other assets. They are all optional and independant from each others.

- folder structure: ```./profiles/``` 

```bash
.
└── profiles
	└── [profile name]
		├── profile.yaml # profile description (optional)
		├── custom.sh # custom functions (optional)
		├── assets # store specific files (optional)
		│	├── background.[image extension] # background image (optional)
		│	├── fonts # fonts in this folder will be installed (optional)
		│	└── terminal.conf # user terminal configuration (optional, ubuntu only)
		└── dotfiles # dotfiles in this folder will be symlinked or hard copied (optional)

```

- YAML schema: ```./profiles/[profile]/profile.yaml``` 

```yaml
style:
  background: [background url]
  overlay: [overlay path]
  colors:
    theme: [theme name]
  fonts:
    name: [font name]
    size: [font size]
    urls:
      - [font url]
packages:
  generic:
    npm:
      - [package name]
    pip3:
      - [package name]
  macos:
    brew:
      - [package name]
  ubuntu:
    ppa:
      - [ppa address] # ppa must be declared before apt
    apt:
      - [package or ppa-package name]
    snap:
      - [package name]
```

- custom functions pattern: ```./profiles/[profile]/custom.sh``` 

```bash
#!bin/bash
#-------------------------------------------------------------------------------
# custom.sh | custom user scripts
#-------------------------------------------------------------------------------

# function name pattern - All OS
[action]_[entry/exit/last](){
    # insert commands below

}# example for an all OS entry function 
install_entry(){
    # insert commands below
}

# function name pattern - OS specific
[action]_[os_type]_[entry/exit/last](){
    # insert commands below
}

# example for a macOS installation entry function 
install_macos_exit(){
    # insert commands below
}

# example for a Ubuntu removal last function 
remove_ubuntu_last(){
    # insert commands below
}
```

### Add a profile

To create a new *profile*, simply duplicate one available in ```/profiles/```, and start editing it as you please.

*Profiles* foldername can be set through the ```-p``` option.

Note: be careful about adding ```git submodules``` into your profiles as you may be in difficulty for retrieving them. See [this open issue.](https://github.com/dear-github/dear-github/issues/214) for various solutions, including Github actions.

## Actions

*Actions* are scripts applied to the *profiles*.

```bash
.
└── src
	└── actions # store actions scripts
		├── install.sh # install packages and dotfiles, based on a profile
		├── remove.sh  # remove packages and dotfiles, based on an installed instance
		└── update.sh # update packages and dotfiles, based on a profile
```

### Add an action

To create an action, simply duplicate one available in ```/src/actions/``` and start editing it as you please.

*Actions* can be set through the ```-a``` option.

## Backgrounds

*Backrounds* are user background images.

### Add a background

*Backrounds* can be set through four methods :
1. ```-B``` option: an url can be provided to set a background
2. profile yaml: an url can be provided to set a background

```yaml
style:
  background: [background url]
```
3. profile asset: a file can be provided to set a background

```bash
.
└── profiles
  └── [profile]
    └── assets #store specific files (optional)
      └── background.[image extension] # background image (optional)
```

4. prompt: a prompt will be launched to set a background from the ones available in ```/src/backgrounds/```

```bash
.
└── src
  └── backgrounds #store actions scripts
    └── [background images]
```

If more than one method is set the priority goes from 1. to 4.

## Themes

*Themes* are terminal color themes.

```bash
.
└── src
  └── themes #store actions scripts
    ├── monokai.conf # a classic monokai theme
    ├── monokai-light.conf # a light monokai theme
    ├── nord.conf # nord theme from articicestudio
    └── nord-light.conf # custom light nord theme
```

### Add a theme

To create a theme, simply duplicate one available in ```/src/themes/``` and start editing it as you please.

```bash
background-color='[color code]'
background-transparency-percent=0
bold-color='[color code]'
foreground-color='[color code]'
palette=['[color code 0]', '[color code 1]', '[color code 2]', '[color code 3]', '[color code 4]', '[color code 5]', '[color code 6]', '[color code 7]', '[color code 8]', '[color code 9]', '[color code 10]', '[color code 11]', '[color code 12]', '[color code 13]', '[color code 14]', '[color code 15]']
```

*Themes* can be set through the ```-t``` option.

## Overlays

Transparent *overlays* can be added on top of users backgrounds.

### Add an overlay

*Overlays* need to be activated with the ```-o``` option.

*Overlays* and can be selected through tree methods :

1. ```-O``` option: the path to a transparent image can be provided to set an overlay
2. profile yaml: a path can be provided to set an overlay

```yaml
style:
  overlay: [overlay path]
```
3. profile asset: a file can be provided to set an overlay

```bash
.
└── profiles
  └── [profile]
    └── assets #store specific files (optional)
      └── overlay.png # overlay image (optional)
```

4. prompt: a prompt will be launched to set an overlay from the ones available in ```/src/background-overlays/```

```bash
.
└── src
  └── background-overlays #store actions scripts
    └── [overlay images]
```

If more than one method is set the priority goes from 1. to 4.

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
| BACKGROUND | b | Define the user background (from /src/backgrounds) | string | filenames fom available /src/backgrounds/ | - |
| BACKGROUND_URL | B | Define the user background (from an url) | string | any .jpg or .png image url | - |
| CONFIG_PATH | c | Define a path to the configuration file |  string | [user defined] | "./src/loco.conf" |
| PROFILES_DIR | d | Define a path for profiles directories | string |  [user defined] | "profiles" |
| DETACHED | D | Define if dotfiles are symbolically linked from repo or from  | boolean | true/false | false |
| HELP | h | Display options and exit | flag | - | - |
| INSTANCES_DIR | i | Define a path for profiles instances | string | [user defined] | "instances" |
| OVERLAY | o | Define if the overlay option is activated | boolean | true/false | false |
| OVERLAY_PATH | O | Define a path for an overlay image  | string | local path | - |
| PROFILE | p | Define the loco profile | string | default, loco-vim, loco-nvim, loco-full | - |
| ROOT | R | Remove the sudo prompt (experimental) | flag | - | - |
| THEME | t | Define the loco color theme | string | monokai, monokai-light, nord, nord-light | - |
| CURRENT_USER | u | Define the current user name (default: \`$USER\`) | string | [user defined] | $USER |
| VERSION | v | Print Version and exit | flag | - | - |
| VERBOSE | V | Verbose mode | flag | - | - |
| WATERMARK | w | Define if a loco watermark is set (needed for remove)| boolean | true/false | true |
| YES | Y | Automate the yes answer (the few left) | flag | - | - |

### Define static options

Options can be set directly into ```/src/loco.conf```.

```bash
.
└── src
	└── loco.conf #stores static options
```

## Other

### Make ```loco``` your own
The first point you need to keep in mind is security. SSH and GPG keys shall not be shared over the public internet, as should not servers configurations. To make ```loco``` your own, you first need to fork it over a private repository, or your own ```git``` server. Then:
- for Gitlab.com or private Gitlab instances
1. Retrieve your [API private token](https://gitlab.com/-/profile/personal_access_tokens)
2. Retrieve the [project ID]
3. Update ```./src/utils/install``` with your information:
```bash
# modify below with your infos #
local branch_name="gh-main"
local git_server="https://gitlab.com"
local project_ID="1234"
local secret_key="ABC-123"
# # # # end of modifications
```
4. modify function call in ```./src/utils/install``` from 
  ```bash
  retrieve_public_archive "$@"
  ``` 
  to 
  ```bash
  retrieve_private_archive "$@"
  ```
5. [build a release](#build-a-release)
6. Git add, commit and push to your ```gitlab``` server.
7. You can now install ```loco``` with this url pattern:

Using wget:
```bash
bash <(wget --content-disposition --header="PRIVATE-TOKEN: [secret key]" -qO- "https://[git server]/api/v4/projects/[project ID]/repository/files/src%2Futils%2Finstall/raw?ref=[branch name]")
```

Using curl:
```bash
bash <(curl --header "PRIVATE-TOKEN: [secret key]" -JLO "https://[git server]/api/v4/projects/[project ID]/repository/files/src%2Futils%2Finstall/raw?ref=[branch name]")
```

Using either (untested) :
```bash
bash <(echo '[secret key]' 'https://[git server]/api/v4/projects/[project ID]/repository/files/src%2Futils%2Finstall/raw?ref=[branch name]'|(read l o; wget --content-disposition --header="PRIVATE-TOKEN: $l -qO- $o 2>/dev/null || curl --header "PRIVATE-TOKEN: $l" -JLO $o));
```

### Build a release
As it is complicated to archive correctly ```git sub-modules``` in *profiles*, ```loco``` provides a release archive in ```/dist/```. To update it, launch ```./src/utils/build_release```.

## Troubleshooting

### ```Dotfiles backup``` is not found
When you install ```loco``` a watermark file ```~/.loco``` is installed. It stores the original dotfiles backup path. Wen you try to remove a profile ```loco``` tries to find this path to restore the original user dotfiles. If the path is broken, either correct the ```~/.loco``` watermark with the correct one or put your dotftiles at the expected path.
If for some reasons, you don't have access to these files, simply remove the ```~/.loco``` file. Previous installation will remain but you will be able to launch a new installation over it.

## Backlog
- actions: add init, save
- actions: improve update and remove (add yaml diff)
- actions: add a "change_background" action
- bug: using remote /profiles/ dir doesn't work with remove
- documentation: add an example row in the options table
- options : add a "none" option
- options : detached in a remote /.dotfiles/ folder
- options : ghost mode leaving no assets prior to action
- packagers: better package managers abstraction
- packagers: add flatpack support
- profiles: add devops, data-scientist...
- themes: implement 16 colors themes (insted of the plain 8)
- UI: display modes (yes, detached...)
- UI: display prompts options as table rows
- to be reported : yq null solution

## Thanks

All of you, ***Eses*** !

Made in bash.