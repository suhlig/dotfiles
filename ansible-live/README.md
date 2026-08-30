# ansible-live

Links the *own* Ansible role checkouts (git repos) into the default Ansible
role search path, so every playbook on this machine uses the latest code from
the working tree — no pushes, no re-installs.

## Why this exists

Ansible resolves a role reference like `suhlig.simple_systemd_service` by
looking for a directory with exactly that name in the role search paths
(`~/.ansible/roles` is the first built-in default entry). Our checkouts are
named after the GitHub repo (`ansible-role-simple-systemd-service`), so they
can never be found directly.

These symlinks bridge the two:

```
~/.ansible/roles/suhlig.simple_systemd_service
    -> ~/git/github.com/uhlig.it/ansible-role-simple-systemd-service
```

## Conventions

| Thing | Rule |
|---|---|
| Repo location | mirrors the GitHub owner: `~/git/github.com/<owner>/ansible-role-<name>` |
| Link name | mirrors the Galaxy identity: `<namespace>.<role_name>` (from `meta/main.yml`) |
| Third-party roles | `ansible-galaxy role install -r requirements.yml` — never cloned into `~/git`, never linked |
| Forks of third-party roles | linked under the *upstream* Galaxy name (override in `galaxy_name()`), so the fork shadows the installed original |
| Own roles in `requirements.yml` | forbidden on this machine — a Galaxy install would replace the symlink (it is fine on CI machines, which have no links) |
| Collections (own, future) | checkouts with `galaxy.yml` at the repo root, linked into `~/.ansible/collections/ansible_collections/<ns>/<name>` |

## Usage

```sh
~/.ansible/ansible-live        # also on PATH as `ansible-live` after bootstrap/stow
```

Run it after cloning, moving, or renaming a role checkout. It is idempotent
and prunes dangling links. `ansible-galaxy role list` shows the linked roles
alongside installed ones — handy for verification.

## Layout

```
~/.dotfiles/common/bin/ansible-live   <- script (git)
~/.dotfiles/ansible-live/README.md    <- this file (git)
~/.ansible/ansible-live               -> symlink to the script
~/.ansible/README.md                  -> symlink to this file
~/.ansible/roles/suhlig.*             <- symlinks created by the script
~/.ansible/roles/...                  <- Galaxy installs (third-party)
```

If `~/.ansible` is ever wiped (cleanup, restore), recreate it by running the
script again and re-installing the third-party requirements.