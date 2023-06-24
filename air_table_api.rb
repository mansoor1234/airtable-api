module AirTableApi
  extend self
  require 'httparty'
  
  def do_get_request(url)
    response = nil
    begin
      response = HTTParty.get(url, {
        headers: self.get_header
      })
    rescue Exception => e
      puts "fail - exception: #{e.inspect}"
    end
    return response.body
    return false if response&.body&.nil? || response&.body&.empty?
    return response.body if response.body
    nil
  end

 def do_post_request(url, payload)
    response = nil
    begin
      response = HTTParty.post(url, {
        body: payload,
        headers: self.get_header
      })
    rescue Exception => e
      puts "=#==== fail - exception: #{e.inspect}"
    end
      response
  end

  def do_patch_request(url, payload)
    response = nil
    begin
      response = HTTParty.patch(url, {
        body: payload,
        headers: self.get_header
      })
    rescue Exception => e
      puts "fail - exception: #{e.inspect}"
    end
    response
  end

  def do_delete_request(url)
    response = nil
    begin
      response = HTTParty.delete(url, {
        headers: self.get_header
      })
    rescue Exception => e
      puts "fail - exception: #{e.inspect}"
    end
    response
  end

  def get_header
    {
      'accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['TOKEN']}"
    }
  end
end