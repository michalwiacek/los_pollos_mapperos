require "los_pollos_mapperos/version"
require "los_pollos_mapperos/cli"
require "los_pollos_mapperos/configuration"

module LosPollosMapperos
  class << self
    attr_accessor :configuration
  end

  self.configuration ||= Configuration.new

  def self.configure
    yield(configuration)
  end
end
