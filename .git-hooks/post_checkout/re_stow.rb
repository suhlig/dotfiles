module Overcommit::Hook::PostCheckout
  class ReStow < Base
    def run
      warn "Running #{self.class}"
      warn applicable_files

      # result = execute(command)
      # return :fail, result.stdout unless result.success?
      :pass
    end
  end
end
