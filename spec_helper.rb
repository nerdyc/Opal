# Tell MacRuby where to find our framework. Use BUILT_PRODUCTS_DIR if set, otherwise look for a build/ or ../build/
# directory
ENV['DYLD_FRAMEWORK_PATH'] = 
  [ENV['BUILT_PRODUCTS_DIR'], "#{File.dirname(__FILE__)}/build/Debug", "#{File.dirname(__FILE__)}/../build/Debug"].detect do |path|
    !path.nil? && File.exist?(path)
  end

# Include the Bacon libraries
require "rubygems"
require "bacon"

# Integrate Mocha into Bacon
require "mocha/standalone"
require "mocha/object"

class Bacon::Context
  include Mocha::API
  alias_method :old_it,:it
  def it(description,&block)
    mocha_setup
    old_it(description,&block)
    mocha_verify
    mocha_teardown
  end
end

# Setup Bacon to report on tests at the end
Bacon.summary_on_exit

framework 'Opal'