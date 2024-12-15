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
  response = HTMLBody.get(page_url)

  doc = Nokogiri::HTML5(response.body.to_s)
  doc.css('body').inner_text.to_s.downcase.gsub(/\W+/, ' ').split
end
