# dotfiles

## Bootstrap

```bash
brew install stow
cd # the target directory needs to be directly underneath $HOME
git clone --recurse-submodules -j8 git@github.com:suhlig/dotfiles.git .dotfiles
cd  .dotfiles
stow common {linux|osx}
```

## Updating

```bash
cd ~/.dotfiles
git pull
git submodule update --init --remote --merge
stow --restow common osx
```

## Switch SSH identities

Separating SSH identities, e.g. between different projects, can be done with `stow`, too:

1. Put the keys into separate directories under `.ssh/identities`:

```bash
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

```bash
$ ssh-switch suhlig
```

# Issues

* `Bad owner or permissions on ~/.ssh/config`

  git doesn't care about permissions except the `x` flag. `chmod 700 ~/.ssh/config` helps.
