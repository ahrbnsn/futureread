class Authenticator


  def self.creds 
    {:key       => ENV['GR_KEY'],
    :sec        => ENV['GR_SECRET'],
    :token      => ENV['TOKEN'],
    :secret     => ENV['SECRET'],
    :search_url => "https://www.goodreads.com/search/index.xml"}
  end


  def self.authenticate
    consumer       = OAuth::Consumer.new(creds[:key], creds[:sec], 
                     :site => 'http://www.goodreads.com')
    @@access_token = OAuth::AccessToken.new(consumer, creds[:token],
                     creds[:secret])
  end


  def self.search(query, page)
    param        = URI::encode(query)
    uri          = URI.parse "#{creds[:search_url]}?key=#{creds[:key]}&q=#{param}&page=#{page}"
    result       = Timeout::timeout(10) { Net::HTTP.get(uri) }
    
    Nokogiri.XML(result)
  end


  def self.token
    @@access_token
  end


  def self.add(pick)
    token.post(
        '/shelf/add_to_shelf.xml', 
        { 'book_id'      =>  pick, 
          'name'         => 'to-read' 
         },  
        { 'Accept'       =>'application/xml', 
          'Content-Type' => 'application/xml' 
        })
  end


  def self.remove(pick)
    token.post(
          '/shelf/add_to_shelf.xml', 
        { 'book_id'      =>  pick, 
          'name'         => 'to-read', 
          'a'            => 'remove'
          },  
        { 'Accept'       => 'application/xml', 
          'Content-Type' => 'application/xml' 
        })
  end

end
