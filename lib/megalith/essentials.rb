class Megalith
  module Essentials
    def param_serialize(parameter, add_prefix=true)
      return "" unless parameter.class == Hash
      ant = Hash.new
      parameter.each do |key, value|
        ant[key.to_sym] = value.to_s
      end
      param = ant.inject(""){|k,v|k+"&#{v[0]}=#{URI.escape(v[1])}"}
      if add_prefix
        param.sub!(/^&/,"?") 
      else
        param.sub!(/^&/,"") 
      end
      return param ? param : ""
    end

    def send_req(url)
      uri = URI.parse(url)

      Net::HTTP.version_1_2
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get(uri.path, 'User-Agent' => USER_AGENT)
        return response.body.toutf8
      end
      return false
    end

    def fetch_subjects(base_url)
      page = send_req(File.join(base_url, "sub", "subjects.txt"))
      subjects = page.split("\n").map{|s| s.gsub(/[^0-9]/, "").to_i}
      return subjects
    end

    def fetch_comments(base_url, key)
      comments_page = send_req(File.join(base_url, "com", "#{key}.res.dat"))
      arr = comments_page.split("\n").map{|c| c.split("<>")}
      return nil if arr[0][0].include?("DOCTYPE")
      comments = []
      arr.each do |comment|
        comments << Comment.new(
          :text => comment[0],
          :name => comment[1],
          :email => comment[2],
          :created_at => Time.parse(comment[3]),
          :point => comment[4],
          :hash => comment[5],
          :host => comment[6],
          :admin_flag => comment[7]
          )
      end
      return comments
    end
  end
end