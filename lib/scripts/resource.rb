class Resource
  attr_accessor :author, :title, :url, :isbn, :publisher, :total, :related_courses
  
  def initialize
    @related_courses = Array.new
  end
  
  def to_json(path)
    if (!File.directory? path)
      Dir.mkdir path
    end
    
    File.open("#{path}/#{@isbn}", "w") do |file|
      file.puts("{")
      file.puts("  \"title\": \"#{@title.gsub(/"/, "\\\"")}\",")
      file.puts("  \"author\": \"#{@author}\",")
      file.puts("  \"isbn\": \"#{@isbn}\",")
      file.puts("  \"url\": \"#{@url}\",")
      file.puts("  \"publisher\": \"#{@publisher}\",")
      file.puts("  \"total\": \"#{@total}\",")

      gb = GoogleBook.new(@isbn)
      file.puts(" \"googlebook\": {")
      file.puts("   \"url\": \"#{gb.url}\",")
      file.puts("   },")

      az = Amazon.new(@isbn)
      file.puts(" \"amazon\": {")
      file.puts("   \"url\": \"#{az.url}\"")
      file.puts("  },")

      file.puts("  \"relatedcourse\": [")
      related_course_added = false
      @related_courses.each do |related_course|
        if related_course_added
          file.puts("  },")
        end
        related_course_added = true
        file.puts("  {")
        file.puts("    \"name\": \"#{related_course.name}\",")
        file.puts("    \"id\": \"#{related_course.id}\"")
      end
      file.puts("    }")
      file.puts("  ]") # related course
      
      file.puts("}")
    end
  end
end