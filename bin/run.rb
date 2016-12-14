#!/usr/bin/env ruby
require_relative '../config/environment'

BookDate.request_book
BookDate.authenticate
BookDate.request_book_id
BookDate.add_to_shelf
BookDate.undo?

