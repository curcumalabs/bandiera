module Bandiera
  class Feature
    attr_reader :name, :group, :description, :enabled

    def initialize(name, group, description, enabled)
      @name        = name
      @group       = group
      @description = description
      @enabled     = enabled
    end
  end
end