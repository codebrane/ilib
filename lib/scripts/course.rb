require 'resource'
require 'relatedcourse'
require 'googlebook'
require 'amazon'

class Course
  attr_accessor :id, :name, :progression, :resource, :year, :institution
  
  def initialize
    @progression = Hash.new
    @resource = Hash.new
  end
  
  def add_progression(progression_name)
    if (@progression.has_key?(progression_name))
      @progression[progression_name] = @progression[progression_name] + 1
    else
      @progression[progression_name] = 1
    end
  end
  
  def add_resource(progression_name, res)
    if (!@resource.has_key?(progression_name))
      # new progression?
      @resource[progression_name] = Array.new
      @resource[progression_name][0] = res
      @resource[progression_name][0].total = 1
    else
      # look for existing title in this progression
      found = false
      @resource[progression_name].each do |resource|
        if (resource.isbn == res.isbn)
          resource.total = resource.total + 1
          found = true
        end
      end
      # new title for this progression
      if (!found)
        @resource[progression_name][@resource[progression_name].length] = res
        @resource[progression_name][@resource[progression_name].length - 1].total = 1
      end
    end
  end
  
  def total_resources
    total = 0
    @resource.keys.each do |key|
      @resource[key].each do |res|
        total = total + res.total
      end
    end
    total
  end
  
  def to_json(json_dir)
    # put it in the correct year directory
    if (!File.directory? "#{json_dir}/#{@year}/course")
      Dir.mkdir "#{json_dir}/#{@year}"
    end
    
    json_file = "#{json_dir}/#{@year}/course/#{@id}"
    
    File.open(json_file, "w") do |file|
      file.puts("[")
      
      file.puts("  {")
      file.puts("    \"name\": \"#{@name}\",")
      file.puts("    \"institution\": \"#{@institution}\",")
      file.puts("    \"year\": \"#{@year}\",")
      file.puts("    \"total\": \"#{total_resources()}\",")
      
      file.puts("    \"progression\": [")
      progression_count = 1
      @progression.keys.each do |key|
        file.puts("       {")
        file.puts("        \"name\": \"#{key}\",")
        file.puts("        \"total\": \"#{@progression[key]}\",")
        file.puts("          \"book\": [")
        resource_count = 1
        @resource[key].each do |res|
          res.to_json("#{json_dir}/#{@year}/resource")
          
          file.puts("              {")
          file.puts("                \"title\": \"#{res.title.gsub(/"/, "\\\"")}\",")
          file.puts("                \"author\": \"#{res.author}\",")
          file.puts("                \"isbn\": \"#{res.isbn}\",")
          file.puts("                \"url\": \"#{res.url}\",")
          file.puts("                \"publisher\": \"#{res.publisher}\",")
          file.puts("                \"total\": \"#{res.total}\",")
          
          gb = GoogleBook.new(res.isbn)
          file.puts("                \"googlebook\": {")
          file.puts("                  \"url\": \"#{gb.url}\"")
          file.puts("                  },")
          
          file.puts("                \"amazon\": {")
          az = Amazon.new(res.isbn)
          file.puts("                  \"url\": \"#{az.url}\"")
          file.puts("                  },")
          
          file.puts("                \"relatedcourse\": [")
          related_courses_count = 1
          res.related_courses.each do |related_course|
            if (related_course.id != id)
              if related_courses_count > 1
                file.puts("                    },")
              end
              related_courses_count += 1
              file.puts("                    {")
              file.puts("                      \"name\": \"#{related_course.name}\",")
              file.puts("                      \"id\": \"#{related_course.id}\"")
            end
          end
          if related_courses_count > 1
            file.puts("                   }")
          end
          file.puts("                  ]") # related course
          
          if resource_count == resource[key].length
          file.puts("              }")
          file.puts("            ]")
          else
          file.puts("              },")
          end
          resource_count += 1
          
        end
        
        if progression_count == progression.keys.length
        file.puts("       }")
        else
        file.puts("       },")
        end
        progression_count += 1
      end
      file.puts("    ]")
      
      file.puts("  }")
      
      file.puts("]")
    end # File.open...
    json_file
  end # def to_json...
end