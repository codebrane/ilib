require 'rexml/document'
require 'net/http'

class GoogleBook
  attr_reader :url, :thumbnail_url, :info_url, :preview_url, :reviews
  
  def initialize(isbn)
    # http://code.google.com/apis/books/docs/static-links.html
    #@url = "http://books.google.com/books?vid=#{isbn}"
    @url = "http://books.google.com/books?isbn=#{isbn}"
  end
  
  # Using this is fine when creating the JSON but the images on the pages
  # cause Google to block the IP.
  def get_info_from_api(isbn)
    content = Net::HTTP.get(URI.parse("http://books.google.com/books/feeds/volumes?q=isbn:#{isbn}"))
    doc = REXML::Document.new(content)
    links = doc.elements.to_a("//feed/entry/link")
    links.each do |link|
      if (link.attributes['rel'] =~ /thumbnail$/)
        @thumbnail_url = link.attributes['href']
      end
      if (link.attributes['rel'] =~ /info$/)
        @info_url = link.attributes['href']
        # This causes Google to block the IP
#        source = Net::HTTP.get(URI.parse(@info_url))
#        @reviews = String.new(source.scan(/Reviews<\/a>&nbsp;\(([0-9])*\)/)[0][0])
      end
      if (link.attributes['rel'] =~ /preview$/)
        @preview_url = link.attributes['href']
      end
    end
  end
end