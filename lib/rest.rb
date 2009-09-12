require 'find'

class REST
  def initialize
  end
  
  def search(search_text)
    in_match = false
    content = ""
    
    File.open(File.join(Dir.getwd, "json/sample/index-sample-2008.txt.json"), "r") do |file|
      content = "["
      
      while (line = file.gets)
        if (in_match)
          content += line
        end
        
        if (line =~ /.*\},.*/)
          in_match = false
        end
        
        if line =~ /.*"name":.*/
          if line =~ /.*#{search_text}.*/i
            in_match = true
            content += "{"
            content += line
          end
        end
      end
      
      content += "{}"
      content += "]"
    end
    
    content
  end
  
  def get_course(course_id)
    content = ""
    File.open(File.join(Dir.getwd, "json/sample/2008/course/#{course_id}"), "r") { |f|
      content = f.read
    }
    content
  end
  
  def get_all_courses
    content = ""
    File.open(File.join(Dir.getwd, "json/sample/index-sample-2008.txt.json"), "r") { |f|
      content = f.read
    }
    content
  end
  
  def book_seach(field, search_text)
    json = "["
    book_added = false
    
    Find.find(File.join(Dir.getwd, "json/sample/2008/course/")) do |path|
      if FileTest.directory?(path)
        next
      end
      
      content = ""
      File.open(File.join(Dir.getwd, "json/sample/2008/course/#{File.basename(path)}"), "r") { |f|
        content = f.read
      }
      
      book_json = JSON.parse(content)
      
      book_json[0]['progression'].each do |progression|
        progression['book'].sort_by { |book| book['total'] }.reverse.each do |book|
          if book[field] =~ /.*#{search_text}.*/i
            if (book_added)
              json += ","
            end
            book_added = true
            json += "{"
            json += "  \"title\": \"#{book['title'].gsub(/"/, "\\\"")}\","
            json += "  \"author\": \"#{book['author']}\","
            json += "  \"isbn\": \"#{book['isbn']}\","
            json += "  \"url\": \"#{book['url']}\","
            json += "  \"publisher\": \"#{book['publisher']}\","
            json += "  \"total\": \"#{book['total']}\","
            json += "  \"course\": \"#{book_json[0]['name']}\","
            json += "  \"googlebook\": {"
            json += "    \"url\": \"#{book['googlebook']['url']}\""
            json += "    },"
            json += "  \"amazon\": {"
            json += "    \"url\": \"#{book['amazon']['url']}\""
            json += "    },"
            json += "  \"relatedcourse\": ["
            related_course_added = false
            book['relatedcourse'].each do |course|
            if (related_course_added)
              json += ","
            end
            related_course_added = true
            json += "    {"
            json += "      \"name\": \"#{course['name']}\","
            json += "      \"id\": \"#{course['id']}\""
            json += "    }"
            end
            json += "    ]"
            json += "}"
          end
        end
      end
      
      
    end
    
    json += "]"
    json
  end
  
  def get_id_for_course_name(course_name)
    content = ""
    File.open(File.join(Dir.getwd, "json/sample/index-sample-2008.txt.json"), "r") { |f|
      content = f.read
    }
    courses = JSON.parse(content)
    
    courses.each do |course|
      if course['name'] == course_name
        return course['id']
      end
    end
  end
  
  def get_book(isbn)
    content = ""
    File.open(File.join(Dir.getwd, "json/sample/2008/resource/#{isbn}"), "r") { |f|
      content = f.read
    }
    book = JSON.parse(content)
    book
  end
end