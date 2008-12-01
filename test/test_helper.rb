$: << File.dirname(__FILE__) + '/../lib'
RAILS_ENV = "test"
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'test/unit'
require 'mocha'
require 'shoulda'