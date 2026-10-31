# Dotfiles Management

This repo is a GNU Stow package tree, checked out at `~/git/github.com/suhlig/dotfiles` and stowed into `$HOME`. To apply (or re-apply) all dotfiles after adding or changing files:

```
stow --target="$HOME" --restow common osx --ignore .DS_Store
```

The `--target="$HOME"` flag is required: GNU Stow defaults to the parent of the repo, which here is `~/git/github.com/suhlig` rather than your home directory, so a bare `stow common osx` would scatter the dotfiles next to the checkout instead of into `$HOME`. The `--ignore .DS_Store` flag is required: Finder creates `.DS_Store` files both in the repo packages and in `$HOME`, and plain `stow common` aborts with a conflict between them instead of stowing anything.

## SSH configuration

`common/.ssh` tracks configuration only: `config`, `config.d/50-main.conf` and `git-signers` (public key material). Private keys, `known_hosts` and `authorized_keys` stay in `~/.ssh` untracked; the whitelist at the bottom of `.gitignore` keeps it that way, so a key that ever lands inside `common/.ssh` cannot be committed.

On a machine where `~/.ssh/config.d` does not exist yet, create it as a real directory before stowing:

```
mkdir -p ~/.ssh/config.d
```

Otherwise Stow folds the directory into a symlink to the checkout, and a machine-local fragment written there would end up inside the repo. Machine-local overrides belong in `~/.ssh/config.d/10-local.conf`, which sorts before the tracked `50-main.conf`; OpenSSH keeps the first value it obtains for a keyword, so the local file wins. Check the merged result with `ssh -G <host>`.
