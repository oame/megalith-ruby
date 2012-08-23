# coding: utf-8

class Megalith  
  class Novel
    include Essentials
    attr_reader :novel
    attr_reader :base_url
    attr_reader :log
    attr_reader :key

    def initialize(base_url, log, key)
      relative_log = (log < 1) ? fetch_subjects(base_url).size : log
      @novel = fetch_novel(base_url, relative_log, key)
      @base_url = base_url
      @log = relative_log
      @key = key
    end
    
    def fetch_novel(base_url, log, key)
      novel_page = send_req(File.join(base_url, "dat", "#{key}.dat"))
      aft = send_req(File.join(base_url, "aft", "#{key}.aft.dat"))
      lines = novel_page.split("\n")
      meta = lines[0].split("<>")
      hash = lines[1]
      text = lines[2, lines.size].join
      comment_count, review_count = meta[4].split("/")
      comments = fetch_comments(base_url, key)
      novel = {
        :title => meta[0],
        :text => text,
        :aft => aft,
        :author => Author.new(:name => meta[1], :email => meta[2], :website => meta[3]),
        :tags => meta[12].split(/[\s　]/),
        :log => relative_log,
        :key => key,
        :created_at => Time.at(key),
        :updated_at => Time.parse(meta[7]),
        :review_count => review_count,
        :comment_count => comment_count,
        :point => meta[5],
        :rate => meta[6],
        :host => meta[8],
        :background_color => meta[9],
        :text_color => meta[10],
        :convert_newline => meta[11],
        :size => text.bytesize / 1024,
        :url => URI.join(base_url, "?mode=read&key=#{key}&log=#{relative_log}").to_s,
        :comments => comments
      }
      return novel
    end
    
    def simple_rating(point)
      # Get cookie
      get_params = param_serialize({
        :mode => :read,
        :key => @key,
        :log => @log
      })
      uri = URI.parse(@base_url)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Get.new(uri.path)
      req["User-Agent"] = USER_AGENT
      res = http.request(req, get_params)
      cookie = res["Set-Cookie"]

      # Post Comment
      post_uri_params = param_serialize({
        :mode => :update,
        :key => @key,
        :log => @log,
        :target => :res
      })
      post_params = param_serialize({:body => "#EMPTY#", :point => point}, false)
      req = Net::HTTP::Post.new(File.join(uri.path, post_uri_params))
      req["Cookie"] = cookie
      req["User-Agent"] = USER_AGENT
      res = http.request(req, post_params)
      return res
    end
    
    def comment(text, params={})
      # Get cookie
      get_params = param_serialize({
        :mode => :read,
        :key => @key,
        :log => @log
      })
      uri = URI.parse(@base_url)
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Get.new(uri.path)
      req["User-Agent"] = USER_AGENT
      res = http.request(req, get_params)
      cookie = res["Set-Cookie"]

      # Post Comment
      post_uri_params = param_serialize({
        :mode => :update,
        :key => @key,
        :log => @log,
        :target => :res
      })
      params.each do |k, v|
        params[k] = v.to_s.tosjis
      end
      post_params = param_serialize({:body => text.tosjis}.update(params), false)
      req = Net::HTTP::Post.new(File.join(uri.path, post_uri_params))
      req["Cookie"] = cookie
      req["User-Agent"] = USER_AGENT
      res = http.request(req, post_params)
      return res
    end
    
    def plain
      return self.text.gsub(/(<br>|\r?\n)/, "")
    end

    def method_missing(action, *args)
      return @novel[action.to_s.to_sym] rescue nil
    end
    
    def params() @novel.keys.map{|k|k.to_sym} ; end
    alias_method :available_methods, :params
    
    def to_hash
      @novel
    end
  end
  
  class Comment
    attr_reader :comment
    
    def initialize(comment)
      @comment = comment
    end
    
    def method_missing(action, *args)
      return @comment[action.to_s.to_sym] rescue nil
    end
    
    def params() @comment.keys.map{|k|k.to_sym} ; end
    alias_method :available_methods, :params
    
    def to_hash
      @comment
    end
  end
  
  class Author
    attr_reader :author
    
    def initialize(author)
      @author = author  
    end
    
    def method_missing(action, *args)
      return @author[action.to_s.to_sym] rescue nil
    end
    
    def params() @author.keys.map{|k|k.to_sym} ; end
    alias_method :available_methods, :params
    
    def to_hash
      @author
    end
  end
  
  class Index
    attr_reader :base_url
    attr_reader :index
    def initialize(base_url, index)
      @base_url = base_url
      @index = index
    end

    def method_missing(action, *args)
      return @index[action.to_s.to_sym] rescue nil
    end
    
    def params() @index.keys.map{|k|k.to_sym} ; end
    alias_method :available_methods, :params
    
    def to_hash
      @index
    end

    def fetch
      Novel.new(@base_url, self.log, self.key)
    end
    alias_method :get, :fetch
  end

  class Subject < Array
    include Essentials
    attr_reader :subject
    attr_reader :base_url
    attr_reader :log
    
    def initialize(base_url, log)
      @subject = fetch_subject(base_url, log)
      super(subject)
      @base_url = base_url
      @log = subject.first.log
    end

    def fetch_subject(base_url, log)
      fs = fetch_subjects(base_url)
      absolute_log = (fs.size <= log || log < 1) ? "" : log
      relative_log = (log < 1) ? fs.size : log
      page = send_req(File.join(base_url, "sub", "subject#{absolute_log}.txt"))
      subject = page.split("\n").map{|i| i.split("<>")}

      indexes = []
      subject.each do |index|
        key = index[0].gsub(/[^0-9]/, "").to_i
        comment_count, review_count = index[5].split("/")
        indexes << Index.new(base_url, {
          :log => relative_log,
          :key => key,
          :title => index[1],
          :author => index[2],
          :created_at => Time.at(key),
          :updated_at => Time.parse(index[8]),
          :review_count => review_count,
          :comment_count => comment_count,
          :point => index[6],
          :tags => index[13].split(/[\s　]/),
          :rate => index[7].to_f,
          :host => index[9],
          :background_color => index[10],
          :text_color => index[11],
          :convert_newline => index[12],
          :size => index[14].to_f,
          :url => URI.join(base_url, "?mode=read&key=#{key}&log=#{absolute_log}").to_s
        })
      end
      return indexes.reverse
    end

    def next_page
      Subject.new(@base_url, @log-1)
    end
    alias_method :next, :next_page

    def prev_page
      Subject.new(@base_url, @log+1)
    end
    alias_method :prev, :prev_page
    
    def latest_log
      fetch_subjects(@base_url).last
    end
  end
end