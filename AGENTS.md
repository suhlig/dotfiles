# Dotfiles Management

This repo is a GNU Stow package tree, checked out at `~/git/github.com/suhlig/dotfiles` and stowed into `$HOME`. To apply (or re-apply) all dotfiles after adding or changing files:

```
stow --target="$HOME" --restow common osx --ignore .DS_Store
```

The `--target="$HOME"` flag is required: GNU Stow defaults to the parent of the repo, which here is `~/git/github.com/suhlig` rather than your home directory, so a bare `stow common osx` would scatter the dotfiles next to the checkout instead of into `$HOME`. The `--ignore .DS_Store` flag is required: Finder creates `.DS_Store` files both in the repo packages and in `$HOME`, and plain `stow common` aborts with a conflict between them instead of stowing anything.

## SSH configuration

ssh is for servers only; git never uses it for GitHub. `common/.ssh` tracks configuration only: `config` and `git-signers` (public key material). Private keys, `known_hosts` and `authorized_keys` stay in `~/.ssh` untracked; the whitelist at the bottom of `.gitignore` keeps it that way, so a key that ever lands inside `common/.ssh` cannot be committed. Runtime files such as `agent/` sockets, `known_hosts` or `identities/` must not exist inside `common/.ssh` in the checkout either: Stow would link them into `~/.ssh`. Delete them if they show up there.

`~/.ssh/config` sets `IgnoreUnknown UseKeychain` in `Host *` so the same file works on Linux. Order matters in it: the first value wins, so `Host shop` has to stay above the `*.tailnet-204f.ts.net` wildcard. Check the merged result with `ssh -G <host>`. Hosts that pin an `IdentityFile` need at least its `.pub` on disk (`~/.ssh/identities/<name>/id_ed25519.pub`): with `IdentitiesOnly yes` and an agent such as 1Password, ssh offers only agent keys that match such a file; without it no key is offered and the login fails.

The first thing `~/.ssh/config` does is `Include ~/.ssh/config.work`, an optional overlay that `dotfiles-ibm` provides. ssh skips it silently if it is missing.

## Git configuration

GitHub is reached over https only, and `gh` is the only credential helper. Do not add `core.sshCommand`, `url.*.insteadOf` rewrites to ssh, or another credential helper.

* `common/.gitconfig` rewrites `git@github.com:` and `ssh://git@github.com/` (and the gist hosts) to https, so old clones and tools with ssh URLs keep working.
* It resets `credential.helper` with an empty value first, because the system gitconfig (Homebrew) sets `osxkeychain`, which would otherwise run before `gh` and could hand out another account's token. Then `credential."https://github.com".helper` is `!gh auth git-credential`.
* `gh auth git-credential` returns a token only for the account named in `username`; it never falls back to the active account. So `credential."https://github.com".username` selects the account: `suhlig` by default, overridden by the org files.
* Identity (name, e-mail, signing) and gh account follow the checkout location: `includeIf "gitdir:~/git/github.com/<org>/"` pulls in `common/.gitconfig.d/orgs/*.conf` (`nerab.conf`, `aishe.conf` for `nowak-reisen` and `speisehof`). There is no matching on remote URLs. Clones and worktrees therefore have to live below `~/git/<host>/<org>/`. The `includeIf` blocks come after `~/.gitconfig.local` on purpose, because git lets the later value win and an organisation's identity must beat a machine-wide default.

The tokens of Aishe (`aidrechs`) and nerab (`nerab`) never exist on the work machine. They are created on a personal machine with `gh auth login -h github.com -p https -w`, once per account, which adds them next to `suhlig`. This repo only ships the configuration; the tests only look at that.

`~/.gitconfig` includes the untracked `~/.gitconfig.local` (machine-local defaults, e.g. a work identity). Create `~/.gitconfig.d` and `~/.gitconfig.d/orgs` as real directories before stowing, because the `dotfiles-ibm` overlay puts files into them too and Stow would otherwise fold them into a symlink to one checkout:

```
mkdir -p ~/.gitconfig.d/orgs
```

Do not place these files under `~/git/github.com/<org>/`: Stow would then own a directory that is also used for checkouts.

`git-signers` lists every key whose signatures should verify, including the work key from `dotfiles-ibm`. `user.useConfigOnly` is deliberately not set: the base config has a default name and e-mail, so it would have no effect.

## Tests

`test/run` builds `test/debian/trixie/Dockerfile.slim`, whose last step runs `test/debian/trixie/verify.sh` (helpers in `test/lib.sh`, which `dotfiles-ibm` sources as well, so keep their names stable). When you change ssh or git config, add or adjust a check there; checks that guard a past bug say so in a comment. The image runs as the unprivileged user `tester`, not root, so permission problems show up. Run `shellcheck -x -P SCRIPTDIR test/lib.sh test/debian/trixie/verify.sh test/run` before committing.

Hooks are managed with pre-commit (`.pre-commit-config.yaml`, scripts in `.git-hooks/`); they are all `repo: local` on purpose. `pre-commit install --overwrite` installs the `pre-commit`, `pre-push` and `post-merge` types (`default_install_hook_types`). The `re-stow` hook has to stay in sync with `stow-dotfiles` in `bootstrap.zsh`.

