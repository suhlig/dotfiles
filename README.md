# dotfiles

# Bootstrap

```command
```

Dotfiles should work without the following, but it's nicer if they are present:

- [atuin](https://atuin.sh/docs)
- [startship](https://https://starship.rs/)

# Updating

```command
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

# Test

```command
docker build -t suhlig/dotfiles-debian-trixie-slim - < test/debian/trixie/slim.docker
docker run -it --rm suhlig/dotfiles-debian-trixie-slim
```
