# Dotfiles Management

This repo is a GNU Stow package tree, checked out at `~/git/github.com/suhlig/dotfiles` and stowed into `$HOME`. To apply (or re-apply) all dotfiles after adding or changing files:

```
stow --target="$HOME" --restow common osx --ignore .DS_Store
```

The `--target="$HOME"` flag is required: GNU Stow defaults to the parent of the repo, which here is `~/git/github.com/suhlig` rather than your home directory, so a bare `stow common osx` would scatter the dotfiles next to the checkout instead of into `$HOME`. The `--ignore .DS_Store` flag is required: Finder creates `.DS_Store` files both in the repo packages and in `$HOME`, and plain `stow common` aborts with a conflict between them instead of stowing anything.

## SSH configuration

`common/.ssh` tracks configuration only: `config`, `config.d/50-main.conf` and `git-signers` (public key material). Private keys, `known_hosts` and `authorized_keys` stay in `~/.ssh` untracked; the whitelist at the bottom of `.gitignore` keeps it that way, so a key that ever lands inside `common/.ssh` cannot be committed. Runtime files such as `agent/` sockets, `known_hosts` or `identities/` must not exist inside `common/.ssh` in the checkout either: Stow would link them into `~/.ssh`. Delete them if they show up there.

`~/.ssh/config` only includes `config.d/*.conf`, so a stray file or a dangling symlink in `config.d` is ignored rather than breaking ssh. `50-main.conf` sets `IgnoreUnknown UseKeychain` so the same file works on Linux. Order matters in it: the first value wins, so `Host shop` has to stay above the `*.tailnet-204f.ts.net` wildcard.

Every `IdentityFile` needs at least its `.pub` on disk (`~/.ssh/identities/<name>/id_ed25519.pub`). With `IdentitiesOnly yes` and an agent such as 1Password, ssh offers only agent keys that match such a file; without it no key is offered and the login fails.

On a machine where `~/.ssh/config.d` does not exist yet, create it as a real directory before stowing:

```
mkdir -p ~/.ssh/config.d
```

Otherwise Stow folds the directory into a symlink to the checkout, and a machine-local fragment written there would end up inside the repo. Machine-local overrides belong in `~/.ssh/config.d/10-local.conf`, which sorts before the tracked `50-main.conf`; OpenSSH keeps the first value it obtains for a keyword, so the local file wins. Check the merged result with `ssh -G <host>`.

## Git configuration

`~/.gitconfig` is tracked and includes, in this order, `~/.gitconfig.d/50-main.conf` and `~/.gitconfig.d/90-osx.conf` (stowed from `common` and `osx`), the untracked `~/.gitconfig.local` (machine-local defaults, e.g. a work identity) and finally `~/.gitconfig.d/95-orgs.conf`. The last one holds the `includeIf` conditions for the per-repository identities in `common/.gitconfig.d/orgs`; it comes after `.gitconfig.local` on purpose, because git lets the later value win and a repository-specific identity must beat a machine-wide default.

`hasconfig:remote.*.url:` compares the URL as written in the repo, before `url.*.insteadOf` rewriting, so `95-orgs.conf` lists both the `git@github.com:` and the `https://github.com/` form of each org.

There is no default `core.sshCommand`: SSH identities come from `~/.ssh/config`. Only the org files set one, with `-F /dev/null` and `-o IgnoreUnknown=UseKeychain` (the latter because `-F /dev/null` drops the `IgnoreUnknown` from `50-main.conf`).

Create `~/.gitconfig.d` and `~/.gitconfig.d/orgs` as real directories before stowing, for the same folding reason as `~/.ssh/config.d`:

```
mkdir -p ~/.gitconfig.d/orgs
```

Do not place these files under `~/git/github.com/<org>/`: Stow would then own a directory that is also used for checkouts. Identities in `.ssh/config.d/50-main.conf` are declared per host rather than in `Host *`, so a per-command `-i` never competes with a wildcard default. An org-level `core.sshCommand` additionally passes `-F /dev/null`, which keeps it independent of `~/.ssh/config` and of any machine-local fragment.

`git-signers` lists every key whose signatures should verify, including the work key from `dotfiles-ibm`. `user.useConfigOnly` is deliberately not set: the base config has a default name and e-mail, so it would have no effect.

## Tests

`test/run` builds `test/debian/trixie/Dockerfile.slim`, whose last step runs `test/debian/trixie/verify.sh` (helpers in `test/lib.sh`, which `dotfiles-ibm` sources as well, so keep their names stable). When you change ssh or git config, add or adjust a check there; checks that guard a past bug say so in a comment. The image runs as the unprivileged user `tester`, not root, so permission problems show up. Run `shellcheck -x -P SCRIPTDIR test/lib.sh test/debian/trixie/verify.sh test/run` before committing.

Hooks are managed with pre-commit (`.pre-commit-config.yaml`, scripts in `.git-hooks/`); they are all `repo: local` on purpose. `pre-commit install --overwrite` installs the `pre-commit`, `pre-push` and `post-merge` types (`default_install_hook_types`). The `re-stow` hook has to stay in sync with `stow-dotfiles` in `bootstrap.zsh`.

