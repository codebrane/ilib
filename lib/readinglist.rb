require 'util'
require 'digest/md5'

class ReadingList
  def ReadingList.create_reading_list(title, email, password)
    id = Util.unique_id
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "w") { |file|
      file.puts("title=#{title}")
      file.puts("owner=#{email}")
      file.puts("password=#{Digest::MD5.hexdigest(password)}")
      file.puts("shared=no")
    }
    id
  end
  
  def ReadingList.get_id(title)
    id = "NOT_FOUND"
    Find.find(File.join(Dir.getwd, "readinglists")) do |path|
      if FileTest.directory?(path)
        next
      end
      
      File.open(File.join(Dir.getwd, "readinglists/#{File.basename(path)}"), "r") { |file|
        file.each_line { |line|
          if line =~ /^title=#{title}/
            return File.basename(path)
          end
        }
      }
    end
    id
  end
  
  def ReadingList.load_reading_list(title, password)
    return_value = "NOT_FOUND"
    Find.find(File.join(Dir.getwd, "readinglists")) do |path|
      if FileTest.directory?(path)
        next
      end
      
      File.open(File.join(Dir.getwd, "readinglists/#{File.basename(path)}"), "r") { |file|
        list_to_load = false
        file.each_line { |line|
          if line =~ /^title=#{title}/
            list_to_load = true
          end
          
          if line =~ /^password=/ && list_to_load
            password_from_list = line.chomp.gsub(/password=/, "")
            if Digest::MD5.hexdigest(password) == password_from_list
              return File.basename(path)
            else
              return_value = "WRONG_PASSWORD"
            end
          end
        }
      }
    end
    return_value
  end
  
  def ReadingList.add_to_reading_list(id, isbn)
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "a+") { |file|
      file.puts("isbn=#{isbn}")
    }
  end
  
  def ReadingList.remove_from_reading_list(id, isbn)
    new_contents = []
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "a+") { |file|
      file.each_line { |line|
        if !(line =~ /^isbn=#{isbn}/)
          new_contents.push line
        end
      }
    }
    
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "w") { |file|
      new_contents.each do |line|
        file.puts(line)
      end
    }
  end
  
  def ReadingList.get_reading_list(id)
    contents = []
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "a+") { |file|
      file.each_line { |line|
        if line =~ /^isbn=.*/
          contents.push line.gsub(/isbn=/, "").chomp
        end
      }
    }
    contents
  end
  
  def ReadingList.is_in_reading_list(id, isbn)
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "r") { |file|
      file.each_line { |line|
        if line =~ /^isbn=#{isbn}/
          return true
        end
      }
    }
    return false
  end
  
  def ReadingList.get_book_count(isbn)
    count = 0
    Find.find(File.join(Dir.getwd, "readinglists")) do |path|
      if FileTest.directory?(path)
        next
      end
      
      File.open(File.join(Dir.getwd, "readinglists/#{File.basename(path)}"), "r") do |file|
        file.each_line do |line|
          if line =~ /^isbn=#{isbn}/
            count += 1
          end
        end
      end
    end
    count
  end
  
  def ReadingList.delete(id)
    File.delete(File.join(Dir.getwd, "readinglists/#{id}"))
  end
  
  def ReadingList.share(id, shared)
    new_contents = []
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "r") { |file|
      file.each_line { |line|
        if line =~ /^shared/
          line = "shared=#{shared}"
        end
        new_contents.push line
      }
    }
    
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "w") { |file|
      new_contents.each do |line|
        file.puts(line)
      end
    }
  end
  
  def ReadingList.is_shared(id)
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "r") { |file|
      file.each_line { |line|
        if line =~ /^shared/
          return line.chomp == "shared=yes"
        end
      }
    }
  end
  
  def ReadingList.get_shared_reading_lists
    shared_reading_lists = Hash.new
    title = ""
    Find.find(File.join(Dir.getwd, "readinglists")) do |path|
      if FileTest.directory?(path)
        next
      end
      
      File.open(File.join(Dir.getwd, "readinglists/#{File.basename(path)}"), "r") { |file|
        file.each_line { |line|
          if line =~ /^title/
            title = line.chomp.gsub(/title=/, "")
            puts title
          end
          if line =~ /^shared=yes/
            puts "here"
            shared_reading_lists[File.basename(path)] = title
          end
        }
      }
    end
    shared_reading_lists
  end
  
  def ReadingList.send_password(id)
    email_to = ""
    new_password = ""
    
    new_contents = []
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "r") { |file|
      file.each_line { |line|
        if line =~ /^owner/
          email_to = line.chomp.gsub(/owner=/, "")
        end
        
        if line =~ /^password/
          new_password = Util.generate_password
          line = "password=#{Digest::MD5.hexdigest(new_password)}\n"
        end
        new_contents.push line
      }
    }
    
    File.open(File.join(Dir.getwd, "readinglists/#{id}"), "w") { |file|
      new_contents.each do |line|
        file.puts(line)
      end
    }
    
    Util.send_email(email_to, "iLib Reading List Password", new_password)
  end
end