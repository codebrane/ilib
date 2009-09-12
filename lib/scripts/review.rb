require 'net/http'

content = Net::HTTP.get(URI.parse("http://books.google.com/books?id=pwUXAQAAIAAJ&dq=isbn:1903365430&ie=ISO-8859-1&source=gbs_gdata"))
#content = Net::HTTP.get(URI.parse("http://books.google.com/books?id=sFgIAAAACAAJ&dq=isbn:0099385716&ie=ISO-8859-1&source=gbs_gdata"))
# Reviews</a>&nbsp;(0)
reviews = content.scan(/Reviews<\/a>&nbsp;\(([0-9])*\)/)
puts content.scan(/Reviews<\/a>&nbsp;\(([0-9])*\)/)[0]
puts reviews[0]
t = String.new(content.scan(/Reviews<\/a>&nbsp;\(([0-9])*\)/)[0][0])
puts t
