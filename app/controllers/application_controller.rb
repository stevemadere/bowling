class ApplicationController < ActionController::Base
  require 'rails_remediation/proper_controller_responses'
  protect_from_forgery
end
