#!/usr/bin/env ruby
require_relative '../config/environment'

Authenticator.authenticate
puts "What would you like to read at some point?"
input = gets.chomp
book = PickBookToRead.new(input)
book.retrieve_results
book.add_top_pick
book.correct?


# BookDate.request_book
# BookDate.authenticate
# BookDate.request_book_id
# BookDate.add_to_shelf
# BookDate.undo?

