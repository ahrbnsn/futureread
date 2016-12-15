#!/usr/bin/env ruby
require_relative '../config/environment'

BookDate.create_token
puts "What would you like to read at some point?"
input = gets.chomp
book = BookDate.new(input)
book.retrieve_results
book.add_top_pick
book.correct?


# BookDate.request_book
# BookDate.authenticate
# BookDate.request_book_id
# BookDate.add_to_shelf
# BookDate.undo?

