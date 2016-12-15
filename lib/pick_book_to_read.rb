class PickBookToRead

  attr_accessor :query, :results, :last_added

  def initialize(query)
    @query       = query
  end

  def retrieve_results
    response = Authenticator.search(query)
    self.results = Nokogiri.XML(response)
  end

  def book_results
    books        = results.css("search work")
    books.collect do |book|
      assign_attributes(book)
    end
  end

  def top_pick 
    book_results[0]
  end

  def assign_attributes(book)
     author     = book.at_css("best_book author name").text
      title      = book.at_css("best_book title").text
      id         = book.at_css("best_book id").text 
      
      {:author => author,
       :title  => title,
       :id     => id}
  end

  def add_top_pick
    add_to_shelf(top_pick)
  end

  def add_to_shelf(pick)
    Authenticator.add(pick[:id])
    self.last_added = pick
    puts "Added #{pick[:title]} by #{pick[:author]}"
  end

  def correct?
    puts "That what you wanted?"
    answer = gets.chomp
    unless answer.downcase.include?("y")
      remove_from_shelf!
      list_all_books
      pick_new_book
    end
  end

  def remove_from_shelf!
    Authenticator.remove(last_added[:id])
    puts "Removed #{last_added[:title]} by #{last_added[:author]}"
    last_added[:removed] = true
  end

  def list_all_books
    book_results.each.with_index(1) do |book, i|
      puts "#{i}. #{book[:title]} | #{book[:author]} "
    end
  end

  def pick_new_book
    puts "What would you like to add?"
    selection = gets.chomp.to_i
    index = selection.to_i - 1
    add_to_shelf(book_results[index])
  end


  def token
    self.class.token
  end

end