module Overcommit::Hook::PostMerge
  class ReStow < Base
    def run
      result = execute("stow --restow common #{platform}")
      return :fail, result.stdout unless result.success?
      :pass
    end

    private

    def platform
      if Overcommit::OS.linux?
        'linux'
      elsif Overcommit::OS.mac?
        'osx'
      else
        raise "Unsupported platform. Must be either 'osx' or 'linux'."
      end
    end
  end
end
