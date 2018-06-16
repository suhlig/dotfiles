# What I usually install on a fresh box

1. Using `apt`:

   ```
   atom
   autokey-gtk
   build-essential
   curl
   dropbox
   nvidia-352
   nvidia-settings
   software-properties-common
   stow
   unattended-upgrades
   vlc
   xsel
   ```

   I also had `libxml2-dev`, but the one in the Brewfile may be sufficient.

1. Using `linuxbrew`:

  Assuming that `stow` already ran and linked the `Brewfile`:

  ```bash
  cd
  brew bundle
  ```

1. Using other means:

   * https://launchpad.net/diodon
   * Slack (google how to get it; snap seems to work fine)

# Additional settings

* [smyck-colors](https://github.com/vcavallo/gnome-terminal-colors-smyck)
