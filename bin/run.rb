#!/usr/bin/env ruby
require_relative '../config/environment'

query = ARGV.join(" ")

if query.length < 1
  puts "What would you like to read at some point?"
  query = gets.chomp
end

Authenticator.authenticate
book = PickBookToRead.new(query)
book.retrieve_results
book.add_top_pick
book.correct?