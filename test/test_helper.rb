$: << File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'active_record'
require 'init'
require 'test/unit'
require 'mocha'
require 'shoulda'
ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'dbfile' => ':memory:')