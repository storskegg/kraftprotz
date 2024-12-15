class ApiController < ActionController::API
  def small
    page_url = URI.parse(request.base_url + root_path + 'tests/small')

    render json: get_body_as_words(page_url).to_json
  end

  def nietzsche
    page_url = URI.parse(request.base_url + root_path + 'tests/nietzsche')

    render json: get_body_as_words(page_url).to_json
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
  })

  doc = Nokogiri::HTML5(response.body.to_s)

  doc.css('body>*').each do |node|
    node_text = node.inner_text.to_s.strip
    Rails.logger.warn "Node text: '#{node_text}'"
    if node_text.empty?
      Rails.logger.warn "Skipping empty node"
      next
    else
      words_s = node_text.downcase.gsub(/\W+/, ' ')
      hash_s = Digest::SHA512.hexdigest words_s
      words = words_s.split
      Rails.logger.warn "Set [#{hash_s}]: #{words}"
      accumulator << words
    end
  end
  # doc.css('body').inner_text.to_s.downcase.gsub(/\W+/, ' ').split
  accumulator
end
