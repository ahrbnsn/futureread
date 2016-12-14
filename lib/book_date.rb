class BookDate

# get oath code
# get input
# make request to goodreads


  def self.request_book
    puts "What do you want to read?"
    @@book = gets.strip
  end

  def self.authenticate
    the_token = ENV['TOKEN']
    the_secret = ENV['SECRET']
    consumer = OAuth::Consumer.new(ENV['GR_KEY'],
                               ENV['GR_SECRET'],
                               :site => 'http://www.goodreads.com')
    @@access_token = OAuth::AccessToken.new(consumer, the_token, the_secret)
  end

  def self.request_book_id
    param = URI::encode(@@book)
    uri = URI.parse "https://www.goodreads.com/search/index.xml?key=#{ENV['GR_KEY']}&q=#{param}"
    response = Timeout::timeout(10) { Net::HTTP.get(uri) }
    doc = Nokogiri.XML(response)

    @@book_id = doc.css("search results best_book id").first.text
  end

  def self.make_review
    response = self.access_token.post('/review.xml', {
             'book_id' => self.book_id,
             'review[review]' => 'test review',
             'review[rating]' => 5
           })
    binding.pry
  end

  def self.add_to_shelf
    # @response = @token.post('/people', @person.to_xml, { 'Accept'=>'application/xml', 'Content-Type' => 'application/xml' })
    shelf = self.access_token.post('/shelf/add_to_shelf.xml', 
             {'book_id' => book_id,
             'name' => 'to-read'},
              { 'Accept'=>'application/xml', 'Content-Type' => 'application/xml' 
              })

  end

  def self.access_token 
    @@access_token
  end

  def self.book_id
    @@book_id
  end

end


# https://www.goodreads.com/shelf/list.xml?key=RWerle4TWzIfezo2iRtJA&user_id