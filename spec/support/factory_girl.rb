
# This enables rpsec tests to use factory girl methods
# without fully qualified names
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

