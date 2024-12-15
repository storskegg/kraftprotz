class ApiController < ActionController::API
  def small
    page_url = URI.parse(request.base_url + root_path + 'tests/small')
    response = HTMLBody.get(page_url)

    doc = Nokogiri::HTML5(response.body.to_s)
    word_list = doc.css('body').inner_text.to_s.downcase.gsub(/\W+/, ' ').split

    render json: word_list.to_json
  end
end

class HTMLBody
  include HTTParty
  format :html
end
