$LOAD_PATH << File.join(Dir.getwd, "lib")

require 'rest'
require 'readinglist'

enable :sessions

# runs before every request is handled
before do
  @rest = REST.new
  
  if session["course_searchtext"] == nil
    session["course_searchtext"] = ""
  end
  
  if session["book_searchtext"] == nil
    session["book_searchtext"] = ""
  end
  
  if session["current_course_name"] == nil
    session["current_course_id"] = "NOT_SET"
    session["current_course_name"] = "Course details"
  end
end

get '/ilib' do
  erb :about
end
get '/ilib/' do
  erb :about
end

get '/ilib/s' do
  erb :test
end

get '/ilib/coursesearch' do
  erb :coursesearch
end
get '/ilib/booksearch' do
  erb :booksearch
end
get '/ilib/allcourses' do
  erb :allcourses, :locals => {:allcourses => JSON.load(@rest.get_all_courses)}
end
get '/ilib/shared_reading_lists' do
  erb :shared_readinglists
end
get '/ilib/shared_reading_list' do
  erb :shared_readinglist
end
get '/ilib/about' do
  erb :about
end

get '/ilib/readinglist' do
  books = []
   if (session["reading_list_id"] != nil)
    ReadingList.get_reading_list(session["reading_list_id"]).each do |isbn|
      books.push(JSON.parse(@rest.book_seach("isbn", isbn)))
    end
    erb :readinglist, :locals => {:books => books, :rest => @rest}
  else
    erb :readinglist
  end
end

get '/ilib/readinglist_create/' do
  title = ""
  if (defined?(params[:title]) && params[:title] != "") &&
     (defined?(params[:email]) && params[:email] != "") &&
     (defined?(params[:password]) && params[:password] != "")
    id = ReadingList.load_reading_list(params[:title], params[:password])
    if (id != "NOT_FOUND")
      erb :readinglist, :locals => {:error => "the reading list for #{params[:title]} already exists. Please load it instead"}
    else
      id = ReadingList.create_reading_list(params[:title], params[:email], params[:password])
      if (id == -1)
        erb :readinglist, :locals => {:error => "can't create readinglist"}
      else
        title = params[:title]
        session["reading_list_title"] = title
        session["reading_list_id"] = id
        session["reading_list_shared"] = "no"
        erb :readinglist, :locals => {:title => title}
      end
    end
  else
    erb :readinglist, :locals => {:error => "Please provide a name, email and password to create the reading list"}
  end
end

get '/ilib/readinglist_load/' do
  if (defined?(params[:title]) && params[:title] != "") && (defined?(params[:password]) && params[:password] != "")
    id = ReadingList.load_reading_list(params[:title], params[:password])
    if (id == "NOT_FOUND")
      erb :readinglist, :locals => {:error => "There doesn't seem to be a reading called \"#{params[:title]}\", please register one", :load_title => params[:title]}
    elsif (id == "WRONG_PASSWORD")
      erb :readinglist, :locals => {:error => "Sorry, but that's the wrong password", :load_title => params[:title]}
    else
      if ReadingList.is_shared(id)
        session["reading_list_shared"] = "yes"
      else
        session["reading_list_shared"] = "no"
      end
      session["reading_list_title"] = params[:title]
      session["reading_list_id"] = id
      redirect '/ilib/readinglist'
    end
  else
    erb :readinglist, :locals => {:error => "Please provide a name and password to load the reading list"}
  end
end

get '/ilib/readinglist_load_shared/:id' do
  books = []
   if (params[:id] != nil)
    ReadingList.get_reading_list(params[:id]).each do |isbn|
      books.push(JSON.parse(@rest.book_seach("isbn", isbn)))
    end
    erb :shared_readinglist, :locals => {:books => books, :rest => @rest}
  else
    erb :shared_readinglist
  end
end

get '/ilib/readinglist_add/:isbn' do
  if (defined?(params[:isbn]))
    ReadingList.add_to_reading_list(session["reading_list_id"], params[:isbn])
    redirect request.referer
  end
end

get '/ilib/readinglist_remove/:isbn' do
  ReadingList.remove_from_reading_list(session["reading_list_id"], params[:isbn])
  redirect request.referer
end

get '/ilib/reading_list_delete' do
  ReadingList.delete(session["reading_list_id"])
  session["reading_list_id"] = nil
  redirect '/ilib/readinglist'
end

get '/ilib/reading_list_share' do
  ReadingList.share(session["reading_list_id"], "yes")
  session["reading_list_shared"] = "yes"
  redirect '/ilib/readinglist'
end

get '/ilib/reading_list_unshare' do
  ReadingList.share(session["reading_list_id"], "no")
  session["reading_list_shared"] = "no"
  redirect '/ilib/readinglist'
end

get '/ilib/reading_list_send_password' do
  if defined?(params[:title]) && params[:title] != ""
    id = ReadingList.get_id(params[:title])
    if id == "NOT_FOUND"
      erb :readinglist, :locals => {:error => "There isn't a reading list called \"#{params[:title]}\""}
    else
      ReadingList.send_password(id)
      erb :readinglist, :locals => {:success_message => "An email has been sent with your new password"}
    end
  else
    erb :readinglist, :locals => {:error => "Please provide a name to reset the password"}
  end
end

get '/ilib/course/:id' do
  if params[:id] == "NOT_SET"
    erb :course_not_set
  else
    json = JSON.parse(@rest.get_course(params[:id]))
    session["current_course_id"] = params[:id]
    session["current_course_name"] = json[0]["name"]
    erb :course, :locals => {:course_id => params[:id], :name => json}
  end
end

get '/ilib/course_search/' do
  if params[:course_searchtext] != ""
    course_search_results_json = JSON.load(@rest.search(params[:course_searchtext]))
    session["course_searchtext"] = params[:course_searchtext]
  end
  erb :coursesearch, :locals => {:course_search_results_json => course_search_results_json}
end

get '/ilib/book_search/' do
  if params[:book_searchtext] != ""
    books_search_results_json = JSON.parse(@rest.book_seach("title", params[:book_searchtext]))
    session["book_searchtext"] = params[:book_searchtext]
  end
  erb :booksearch, :locals => {:books_search_results_json => books_search_results_json, :rest => @rest}
end

get '/ilib/book/:isbn' do
  erb :book, :locals => {:book => @rest.get_book(params[:isbn])}
end
