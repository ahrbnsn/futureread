require 'bundler/setup'
require 'open-uri'
require_relative "../lib/pick_book_to_read.rb"
require_relative "../lib/authenticator.rb"
Bundler.require

Dotenv.load