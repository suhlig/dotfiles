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

# GitHub access

Git talks to GitHub over https; `gh` supplies the credentials, so no ssh key is needed. Log in once per account:

```sh
gh auth login -h github.com -p https -w
gh auth status
```

The account is chosen by where the checkout lives (`~/git/<host>/<org>/<repo>`): `~/.gitconfig` includes `common/.gitconfig.d/orgs/*.conf` for `~/git/github.com/nerab/`, `nowak-reisen/` and `speisehof/`, which set name, e-mail and `credential.https://github.com.username`. Everything else uses `suhlig`.

git gets its credentials from `~/bin/gh-git-credential` (`common/bin/gh-git-credential`). Calling `gh auth git-credential` directly is not enough: since gh 2.105 it serves only the active account and hands back nothing when git asks for another one. The wrapper asks it first and then falls back to `gh auth token --user` for the account named in `credential.https://github.com.username`, so no account has to be switched.

On a personal machine, log in as the other accounts too, once each, in the browser flow as the respective user; `gh auth status` then lists all three, and nothing needs to be switched. These two accounts are never used on the work machine.

```sh
gh auth login -h github.com -p https -w   # as nerab
gh auth login -h github.com -p https -w   # as aidrechs
gh auth status
```

When moving a machine from the old setup (osxkeychain as credential helper), remove the cached credentials once after re-stowing, so no stale token is left behind (repeat with `host=github.ibm.com` and `host=gist.github.ibm.com` where applicable):

```sh
printf 'protocol=https\nhost=github.com\n\n' | git credential-osxkeychain erase
```

ssh is used for servers only; see `common/.ssh/config`.

# Issues

* `Bad owner or permissions on ~/.ssh/config`

  git doesn't care about permissions except the `x` flag. `chmod 700 ~/.ssh/config` helps.

# Test

The slim image stows the dotfiles in a fresh Debian trixie container as an unprivileged user and runs `test/debian/trixie/verify.sh`; the build fails if a check fails. The checks cover shell start-up, the ssh host config (`ssh -G`), the ssh-to-https rewrites, the `gh` credential helper (including its fallback to a non-active account), and identity and gh account per organisation directory (`git config`).

```command
test/run                                     # slim image only, fails on any broken check
docker buildx bake                           # slim and full image (full needs network)
docker run -it --rm dotfiles-debian-trixie-full
```

[pre-commit](https://pre-commit.com) runs the hooks in `.pre-commit-config.yaml`: a trailing-whitespace check on commit, `test/run` before every push (`.git-hooks/docker-test`; it only warns if Docker is not running) and a re-stow after every merge or pull (`.git-hooks/re-stow`). Install it with `brew install pre-commit` (or `pipx install pre-commit`), then run `pre-commit install --overwrite` in the checkout; `--overwrite` is needed because the git template in `common/.git-template` already installs a `pre-commit` shim. All hooks are local, so nothing is fetched from a remote (which would need credentials). [dotfiles-ibm](https://github.ibm.com/Steffen-Uhlig/dotfiles-ibm) builds on the slim image and reuses `test/lib.sh`.
