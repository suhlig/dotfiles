# Dotfiles Management

This repo is a GNU Stow package tree, checked out at `~/git/github.com/suhlig/dotfiles` and stowed into `$HOME`. To apply (or re-apply) all dotfiles after adding or changing files:

```
stow --target="$HOME" --restow common osx --ignore .DS_Store
```

The `--target="$HOME"` flag is required: GNU Stow defaults to the parent of the repo, which here is `~/git/github.com/suhlig` rather than your home directory, so a bare `stow common osx` would scatter the dotfiles next to the checkout instead of into `$HOME`. The `--ignore .DS_Store` flag is required: Finder creates `.DS_Store` files both in the repo packages and in `$HOME`, and plain `stow common` aborts with a conflict between them instead of stowing anything.
