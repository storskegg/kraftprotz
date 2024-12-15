require_dependency 'processor/pdf/pdf_processor'

class TestsController < ApplicationController
  def index
  end

  def nietzsche
  end

  def small
    url = request.base_url + root_path + 'media/pdf/small.pdf'

    # doesn't like non-file urls
    # pdf_processor(url)
  end
end
