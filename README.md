# dotfiles

## Bootstrap

```
{yum|brew} install stow
git clone git@github.com:suhlig/dotfiles.git .dotfiles
cd  ~/.dotfiles
stow common {linux|osx}
```

# Issues

* `Bad owner or permissions on ~/.ssh/config`

  git doesn't care about permissions except the `x` flag. `chmod 700 ~/.ssh/config` helps.
