# Dotfiles Management

This repo is a GNU Stow package tree, stowed into `$HOME` from the repo root. To apply (or re-apply) all dotfiles after adding or changing files:

```
stow --restow common osx --ignore .DS_Store
```

The `--ignore .DS_Store` flag is required: Finder creates `.DS_Store` files both in the repo packages and in `$HOME`, and plain `stow common` aborts with a conflict between them instead of stowing anything.
