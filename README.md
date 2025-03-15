# dotfiles

## Bootstrap

```sh
brew install stow zsh-vi-mode zsh-syntax-highlighting zsh-autosuggestions
cd # the target directory needs to be directly underneath $HOME
git clone git@github.com:suhlig/dotfiles.git .dotfiles
cd  .dotfiles
stow common {linux|osx}
brew bundle --global
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Once tpm was installed, press `<prefix>I` to install all plugins.

## Supporting Software

Dotfiles should work without the following, but it's nicer if they are present:

- [atuin](https://atuin.sh/docs/)

## Updating

```sh
cd ~/.dotfiles
git pull
stow --restow common osx
brew bundle --global
```

## Switch SSH identities

Separating SSH identities, e.g. between different projects, can be done with `stow`, too:

1. Put the keys into separate directories under `.ssh/identities`:

```sh
$ tree ~/.ssh/
/home/suhlig/.ssh/
├── authorized_keys
├── identities
│   ├── other
│   │   ├── id_rsa
│   │   └── id_rsa.pub
│   └── suhlig
│       ├── id_rsa
│       └── id_rsa.pub
└── known_hosts
```

2. Switch identities by specifying the name:

```sh
$ ssh-switch suhlig
```

# Issues

* `Bad owner or permissions on ~/.ssh/config`

  git doesn't care about permissions except the `x` flag. `chmod 700 ~/.ssh/config` helps.
