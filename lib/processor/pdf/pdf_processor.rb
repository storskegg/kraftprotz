require "poppler"

def pdf_processor(url)
  Rails.logger.debug "Processing PDF from #{url}"

  acc = []

  doc = Poppler::Document.new(url)
  doc.each { |page| acc << page.text }

  acc.join
end
