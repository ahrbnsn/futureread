class BookDate
  
  KEY        = 
  APP_SECRET = ENV['GR_SECRET']
  TOKEN      = ENV['TOKEN']
  SECRET     = ENV['SECRET']
  SEARCH_URL = "https://www.goodreads.com/search/index.xml"

  def self.creds 
    {:key       => ENV['GR_KEY'],
    :sec        => ENV['GR_SECRET'],
    :token      => ENV['TOKEN'],
    :secret     => ENV['SECRET'],
    :search_url => "https://www.goodreads.com/search/index.xml"}
  end
  
  def self.create_token
    consumer       = OAuth::Consumer.new(creds[:key], creds[:sec], :site => 'http://www.goodreads.com')
    @@access_token = OAuth::AccessToken.new(consumer, creds[:token], creds[:secret])
  end

  def self.token
    @@access_token
  end


  attr_accessor :query, :results, :last_added

  def initialize(query)
    @query       = query
  end

  def retrieve_results
    param        = URI::encode(query)
    uri          = URI.parse "#{SEARCH_URL}?key=#{ENV['GR_KEY']}&q=#{param}"
    response     = Timeout::timeout(10) { Net::HTTP.get(uri) }
    self.results = Nokogiri.XML(response)
  end

  def book_results
    books    = results.css("search work")
    books.collect do |book|
      author = book.at_css("best_book author name").text
      title  = book.at_css("best_book title").text
      id     = book.at_css("best_book id").text 
      
      {:author => author,
       :title  => title,
       :id     => id}
     end
  end

  def top_pick 
    book_results[0]
  end

  def add_top_pick
    add_to_shelf(top_pick)
  end

  def add_to_shelf(pick)
    token.post('/shelf/add_to_shelf.xml', 
              {'book_id' => pick[:id], 'name' => 'to-read'},  
              { 'Accept'=>'application/xml', 'Content-Type' => 'application/xml' 
              })
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
    token.post('/shelf/add_to_shelf.xml', 
              {'book_id' => last_added[:id], 'name' => 'to-read', 'a' => 'remove'},  
              { 'Accept'=>'application/xml', 'Content-Type' => 'application/xml' 
              })
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



  # def self.request_book_id
  #   param = URI::encode(@@book)
  #   uri = URI.parse "#{SEARCH_URL}?key=#{ENV['GR_KEY']}&q=#{param}"
  #   response = Timeout::timeout(10) { Net::HTTP.get(uri) }
  #   doc = Nokogiri.XML(response)

  #   @@book_id = doc.css("search results best_book id").first.text
  #   @@author = doc.css("search results best_book author name").first.text
  #   @@book_title = doc.css("best_book title").first.text
  # end


  # def self.add_to_shelf
  #   self.access_token.post('/shelf/add_to_shelf.xml', 
  #            {'book_id' => book_id,
  #            'name' => 'to-read'},
  #             { 'Accept'=>'application/xml', 'Content-Type' => 'application/xml' 
  #             })
  #   puts "Added #{@@book_title} by #{@@author}"
  # end

  def self.undo?
    puts "Wrong choice?"
    input = gets.chomp
    if input.downcase.include?("y") 
      self.access_token.post('/shelf/add_to_shelf.xml', 
               {'book_id' => book_id,
               'name' => 'to-read',
               'a' => 'remove'},
                { 'Accept'=>'application/xml', 'Content-Type' => 'application/xml' 
                })
      puts "Ok, deleted #{@@book_title} by #{@@author}"
    end
  end



  def self.access_token 
    @@access_token
  end


  def self.book_id
    @@book_id
  end

end