# dotfiles

# Bootstrap

One-off:

```shell
git clone https://github.com/suhlig/dotfiles.git ~/git/github.com/suhlig/dotfiles
cd ~/git/github.com/suhlig/dotfiles && ./bootstrap.zsh
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
    chdir: /home/suhlig/git/github.com/suhlig/dotfiles
    creates: ~/.zshrc
```

# Updating

TODO

# SSH identities

Separate identities live in their own directories under `.ssh/identities`:

```sh
$ tree ~/.ssh/
/home/suhlig/.ssh/
├── authorized_keys
├── identities
│   ├── other
│   │   ├── id_ed25519
│   │   └── id_ed25519.pub
│   └── suhlig
│       ├── id_ed25519
│       └── id_ed25519.pub
└── known_hosts
```

Identities are selected per repository, not switched globally. Shared settings are stowed as fragments (`common/.gitconfig.d/50-main.conf` and `osx/.gitconfig.d/90-osx.conf`) and included from the tracked `~/.gitconfig`; the untracked `~/.gitconfig.local` is read last, so machine-local overrides win. `50-main.conf` sets a default `core.sshCommand` and uses `includeIf` to pull in one of the org files under `common/.gitconfig.d/orgs`:

```ini
[includeIf "hasconfig:remote.*.url:git@github.com:nowak-reisen/**"]
  path = ~/.gitconfig.d/orgs/nowak-reisen.conf
```

Every `core.sshCommand` names its key explicitly, so whatever sits at `~/.ssh/id_ed25519` is never consulted.

Identities in `50-main.conf` are declared per host, never in `Host *`, so a per-command `-i` never competes with a wildcard default. An overriding `core.sshCommand` also passes `-F /dev/null`, which keeps it independent of `~/.ssh/config` — including any machine-local fragment — so only the named key can be offered:

```ini
[core]
  sshCommand = "ssh -F /dev/null -o IdentitiesOnly=yes -o UseKeychain=yes -o AddKeysToAgent=yes -o StrictHostKeyChecking=accept-new -i ~/.ssh/identities/aidrex/id_ed25519"
```

# Issues

* `Bad owner or permissions on ~/.ssh/config`

  git doesn't care about permissions except the `x` flag. `chmod 700 ~/.ssh/config` helps.

# Test

```command
docker buildx bake
docker run -it --rm dotfiles-debian-trixie-full
```
