class PickBookToRead

  attr_accessor :query, :results, :last_added, :page

  def initialize(query)
    @query       = query
    @page        = 1
  end

  def quick_pick
    retrieve_results
    add_top_pick
    correct?
  end


  def choosy_pick
    retrieve_results
    list_all_books
    pick_new_book
    correct?
  end


  def retrieve_results
    self.results = Authenticator.search(query, page)
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
    author      = book.at_css("best_book author name").text
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
    answer = $stdin.gets.chomp
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
    puts "Select a number 1-20, 'none', or 'more'"
    selection = $stdin.gets.chomp

    case selection
    when /n/
      exit
    when /m/
      self.page += 1
      choosy_pick
    else 
      index = selection.to_i - 1
      add_to_shelf(book_results[index])
    end
  end


  def token
    self.class.token
  end

end
