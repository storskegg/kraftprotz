class ApiController < ActionController::API
  def small
    begin
      page_url = URI.parse(request.base_url + root_path + 'tests/small')
      words = get_body_as_words(page_url)
      render json: words.to_json
    rescue => e
      Rails.logger.error "Error fetching page: #{e.message}"
      head 500
      render json: { error: "An error occurred", error_message: "#{e.message}" }.to_json
    end
  end

  def nietzsche
    begin
      page_url = URI.parse(request.base_url + root_path + 'tests/nietzsche')
      words = get_body_as_words(page_url)
      render json: words.to_json
    rescue => e
      Rails.logger.error "Error fetching page: #{e.message}"
      head 500
      render json: { error: "An error occurred", error_message: "#{e.message}" }.to_json
    end
  end
end

class HTMLBody
  include HTTParty
  format :html
end

def get_body_as_words(page_url)
  accumulator = []

  response = HTMLBody.get(page_url, {
    headers: {
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language" => "en-US,en;q=0.5",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:134.0) Gecko/20100101 Firefox/134.0"
    },
    open_timeout: 500.in_milliseconds,
    write_timeout: 1.seconds,
    read_timeout: 3.seconds
  })

  response.inspect

  doc = Nokogiri::HTML5(response.body.to_s)

  doc.css('body>*').each do |node|
    result = prepare_line(node.inner_text.to_s.strip)

    if result[:words].empty?
      Rails.logger.warn "Skipping empty node"
      next
    else
      Rails.logger.warn "Set [#{result[:hash_s]}]: #{result[:words_s]}"
      accumulator << result[:words]
    end
  end

  accumulator.flatten
end

def prepare_line(line)
  result = new Line
  temp = line.gsub(/[\W\d_]+/, ' ').strip.downcase
  if temp.empty?
    result
  end

  result.set(temp)

  result
end

class Line
  @words = []
  @words_s = ""
  @hash_s = ""

  def words
    @words
  end

  def hash_s
    @hash_s
  end

  def words_s
    @words_s
  end

  def set(words_s)
    @words_s = words_s
    @hash = Digest::SHA256.hexdigest words_s
    @words = words_s.split
  end
end
