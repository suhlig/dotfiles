module Overcommit::Hook::PostMerge
  # Keep in sync with stow-dotfiles in bootstrap.zsh and with AGENTS.md:
  # --target is required because stow otherwise targets the parent of the checkout,
  # --ignore .DS_Store because Finder-created files make stow abort with a conflict.
  class ReStow < Base
    def run
      result = execute(['stow', '--target', Dir.home, '--ignore', '.DS_Store', '--restow', 'common', platform])
      return :fail, result.stderr.empty? ? result.stdout : result.stderr unless result.success?
      :pass
    end

    private

    def platform
      if Overcommit::OS.linux?
        'linux'
      elsif Overcommit::OS.mac?
        'osx'
      elsif Overcommit::OS.windows?
        'windows'
      else
        raise "Unsupported platform. Must be either 'osx', 'linux' or 'windows'."
      end
    end
  end
end
