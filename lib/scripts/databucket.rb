require 'resource'

class DataBucket
  attr_accessor :id, :name, :publisher, :title, :progression, :resource, :year, :institution
  
  def initialize
  end
  
  def clear
    @id = ""
    @name = ""
    @publisher = ""
    @title = ""
    @progression = ""
    @resource = nil
    @year = ""
    @institution = ""
  end
end