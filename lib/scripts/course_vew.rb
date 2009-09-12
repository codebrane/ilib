require 'rexml/document'
require 'rexml/streamlistener'
require 'databucket'
require 'course'
require 'resource'
require 'relatedcourse'
include REXML


class MosaicListener
  include StreamListener
  
  attr_reader :data_bucket, :courses, :in_course_name, :in_progression, :in_publisher, :in_title, :in_resource,
              :in_global_id, :in_author, :in_url, :in_year, :in_institution,
              :json_files_dir, :index_file, :resources_in_courses
  
  def initialize(json_dir, index_file)
    @json_files_dir = json_dir
    @index_file = index_file
    @courses = Hash.new
    @data_bucket = DataBucket.new
    @resources_in_courses = Hash.new
    @in_use_record_collection = false
    @in_course_name = false
    @in_progression = false
    @in_publisher = false
    @in_title = false
    @in_resource = false
    @in_global_id = false
    @in_author = false
    @in_url = false
    @in_year = false
    @in_institution = false
  end
  
  def tag_start(name, attrs)
    if (name == "useRecord")
      @data_bucket.clear
    end
    
    if (name == "publisher")
      @in_publisher = true
    end
    
    if (name == "courseName")
      @in_course_name = true
    end
    
    if (name == "progression")
      @in_progression = true
    end
    
    if (name == "title")
      @in_title = true
    end
    
    if (name == "resource")
      @in_resource = true
      @data_bucket.resource = Resource.new
    end
    
    if (name == "globalID")
      @in_global_id = true
    end
    
    if (name == "author")
      @in_author = true
    end
    
    if (name == "catalogueURL")
      @in_url = true
    end
    
    if (name == "academicYear")
      @in_year = true
    end
    
    if (name == "institution")
      @in_institution = true
    end
  end
  
  def tag_end(name)
    if (name == "useRecord")
      if (@data_bucket.name != "")
        # isbn -> Array(course name, id)
        if (!@resources_in_courses.has_key?(@data_bucket.resource.isbn))
          @resources_in_courses[@data_bucket.resource.isbn] = Array.new
        end
        found = false
        @resources_in_courses.keys.each do |key|
          @resources_in_courses[key].each do |res|
            if (res.id == @data_bucket.id)
              found = true
            end
          end
        end
        if (!found)
          related_course = RelatedCourse.new
          related_course.name = @data_bucket.name
          related_course.id = @data_bucket.id
          @resources_in_courses[@data_bucket.resource.isbn].push(related_course)
        end
        
        if (!@courses.has_key?(@data_bucket.id))
          puts "#{@data_bucket.name} --> #{@data_bucket.id}"
          @courses[@data_bucket.id] = Course.new
          @courses[@data_bucket.id].id = @data_bucket.id
          @courses[@data_bucket.id].name = @data_bucket.name
          @courses[@data_bucket.id].year = @data_bucket.year
          @courses[@data_bucket.id].institution = @data_bucket.institution
        end
        @courses[@data_bucket.id].add_progression(@data_bucket.progression)
        @courses[@data_bucket.id].add_resource(@data_bucket.progression, @data_bucket.resource)
      
#        json_file = @courses[@data_bucket.id].to_json(@json_files_dir)
#        File.open(@index_file, "a") do |file|
#          file.puts("#{@data_bucket.name},#{json_file},#{@courses[@data_bucket.id].total_resources}")
#        end
      end
    end
    
    if (name == "publisher")
      @in_publisher = false
    end
    
    if (name == "courseName")
      @in_course_name = false
    end
    
    if (name == "progression")
      @in_progression = false
    end
    
    if (name == "title")
      @in_title = false
    end
    
    if (name == "resource")
      @in_resource = false
    end
    
    if (name == "globalID")
      @in_global_id = false
    end
    
    if (name == "author")
      @in_author = false
    end
    
    if (name == "catalogueURL")
      @in_url = false
    end
    
    if (name == "academicYear")
      @in_year = false
    end
    
    if (name == "institution")
      @in_institution = false
    end
    
    if (name == "useRecordCollection")
      # isbn -> Array(course name, id)
      @resources_in_courses.keys.each do |isbn|
        @courses.keys.each do |key|
          @courses[key].resource.keys.each do |reskey|
            @courses[key].resource[reskey].each do |resource|
              if (resource.isbn == isbn)
                resource.related_courses = @resources_in_courses[isbn]
#                puts "#{@courses[key].name} -> #{isbn}"
              end
            end
          end
        end
      end
      
      File.open(@index_file, "w") do |file|
        @courses.keys.each do |key|
          puts "json: " + @courses[key].name
          json_file = @courses[key].to_json(@json_files_dir)
          file.puts("#{@courses[key].name},#{json_file},#{@courses[key].total_resources}")
#          sleep(5)
        end
      end
      
      File.open("#{@index_file}.json", "w") do |file|
        file.puts("[")
        json_index_count = 1
        @courses.keys.each do |key|
          if json_index_count > 1
            file.puts("  },")
          end
          json_index_count += 1
          file.puts("  {")
          file.puts("    \"name\": \"#{@courses[key].name}\",")
          file.puts("    \"id\": \"#{@courses[key].id}\",")
          file.puts("    \"total\": \"#{@courses[key].total_resources}\"")
        end
        file.puts("  }")
        file.puts("]")
      end
    end
  end

  def text(data)
    if (@in_publisher)
      @data_bucket.resource.publisher = data
    end
    
    if (@in_title)
      @data_bucket.resource.title = data
    end    
    
    if (@in_course_name)
      id = data.downcase.gsub(/ /, "").gsub(/,/, "").gsub(/:/, "").gsub(/-/, "")
                        .gsub(/\(/, "").gsub(/\)/, "").gsub(/&/, "").gsub(/\//, "")
                        .gsub(/\./, "").gsub(/;/, "")
      @data_bucket.id = id
      @data_bucket.name = data
    end
    
    if (@in_progression)
      @data_bucket.progression = data
    end
    
    if (@in_global_id)
      @data_bucket.resource.isbn = data
    end
    
    if (@in_author)
      @data_bucket.resource.author = data
    end
    
    if (@in_url)
      @data_bucket.resource.url = data
    end
    
    if (@in_year)
      @data_bucket.year = data
    end
    
    if (@in_institution)
      @data_bucket.institution = data
    end
  end
end

# ruby course_vew.rb ../xml/mosaic.2008.sampledata.xml ../../json/sample ../../json/sample/index-sample-2008.txt
if (ARGV.length != 3)
  puts "Usage:"
  puts "ruby course_view.rb EXPORT_FILE JSON_DIR INDEX_FILE"
  puts "e.g."
  puts "ruby course_view.rb mosaic.xml json json/2008/index.txt"
  exit
end

sax_handler = MosaicListener.new(ARGV[1], ARGV[2])
xmlfile = File.new(ARGV[0])
Document.parse_stream(xmlfile, sax_handler)

