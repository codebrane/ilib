class Amazon
  attr_reader :url
  
  def initialize(isbn)
    # http://en.wikipedia.org/wiki/Amazon_Standard_Identification_Number
    @url = "http://www.amazon.co.uk/gp/product/#{isbn}"
  end
end