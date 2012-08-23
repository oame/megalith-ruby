# coding: utf-8

require "kconv"
require "net/http"
require "time"
require "uri"

$LOAD_PATH.unshift(File.expand_path("../", __FILE__))
require "megalith/version"
require "megalith/essentials"
require "megalith/scheme"

class Megalith
  attr_accessor :base_url
  USER_AGENT = "Megalith Ruby Wrapper #{Megalith::VERSION}"

  def initialize(base_url)
    @base_url = base_url
  end
  
  def get(args={})
    args[:log] ||= 0
    if args.has_key?(:key)
      Novel.new(@base_url, args[:log], args[:key])
    else
      Subject.new(@base_url, args[:log])
    end
  end

  #def search(query, args={})
  #  page = send_req({:mode => :search, :type => (args[:type] ? args[:type] : :insubject), :query => query.tosjis})
  #  parse_index(page)
  #end
end
