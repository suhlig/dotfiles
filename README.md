# dotfiles

## Bootstrap

1. Install [RCM](https://github.com/thoughtbot/rcm)
1. `git clone https://github.com/nerab/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`
1. `rcup -t osx` or `rcup -t linux`

## Post-install steps

* Link sublime preferences

  `rcrc` cannot cope with files that do not start with a dot.

        ln -s ~/.dotfiles/config/sublime-text-3/Packages/User/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
