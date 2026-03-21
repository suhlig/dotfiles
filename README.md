# dotfiles

# Bootstrap

One-off:

```shell
git clone https://github.com/suhlig/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.zsh
```

TODO For usage in an Ansible playbook, the dotfiles repo is a role itself, so that we can use it like this:

```yaml
- name: Sample playbook to deploy suhlig.foundation.dotfiles
  hosts: all
  roles:
    - role: suhlig.foundation.dotfiles
      become: true
      tags: [ suhlig, bootstrap, foundation ]
```

Part of the role is a task that clones the dotfiles repo and then calls bootstrap:

```yaml
- name: Setup environment
  shell: ./bootstrap.zsh
  args:
    chdir: /home/suhlig/.dotfiles
    creates: ~/.zshrc
```

# Updating

TODO

# SSH identities

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
docker buildx bake
docker run -it --rm dotfiles-debian-trixie-test
```
