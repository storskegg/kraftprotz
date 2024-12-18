require 'preprocessor/preprocessor'

module PDFHandling
  Per_Line = 1
  Per_Page = 2
end

PDF_HANDLE_METHOD = PDFHandling::Per_Page

class ApiController < ActionController::API
  def v1_process_site

  end

  def small
    # http://localhost:3000/media/pdf/small.pdf
    page_url = URI.parse(request.base_url + root_path + 'media/pdf/small.pdf')
    words = get_pdf_as_words(page_url)
    render json: words.to_json
  end

  def nietzsche
    page_url = URI.parse(request.base_url + root_path + 'tests/nietzsche')
    words = get_html_as_words(page_url)
    render json: words.to_json
  end
end

def get_pdf_as_words(pdf_url)
  response = HTTParty.get(pdf_url, {
    headers:{
      "Accept" => "application/pdf",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:134.0) Gecko/20100101 Firefox/134.0"
    },
    open_timeout: 500.in_milliseconds,
    write_timeout: 1.seconds,
    read_timeout: 5.seconds,
  })

  response.inspect

  accumulator = PreProcessor::WordAccumulator.new

  if response.code == 200
    Tempfile.create do |file|
      file.binmode
      file.write(response.body)

      temp_path = File.absolute_path(file.path.to_s)
      doc = Poppler::Document.new(temp_path)

      if PDF_HANDLE_METHOD == PDFHandling::Per_Line
        doc.each do |page|
          page.text.to_s.split(/\n/).each do |line|
            result = prepare_line(line)
            if result.words.empty?
              Rails.logger.warn "Skipping empty page"
              next
            else
              Rails.logger.warn "Set [#{result.hash_s}]: #{result.words_s}"
              accumulator.add_words result.words
            end
          end
        end
      elsif PDF_HANDLE_METHOD == PDFHandling::Per_Page
        doc.each do |page|
          result = prepare_line(page.text.to_s)
          if result.words.empty?
            Rails.logger.warn "Skipping empty page"
            next
          else
            Rails.logger.warn "Set [#{result.hash_s}]: #{result.words_s}"
            accumulator.add_words result.words
          end
        end
      end
    end
  end

  accumulator
end

def get_html_as_words(page_url)
  begin
    response = HTTParty.get(page_url, {
      headers: {
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" => "en-US,en;q=0.5",
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:134.0) Gecko/20100101 Firefox/134.0"
      },
      open_timeout: 500.in_milliseconds,
      write_timeout: 1.seconds,
      read_timeout: 3.seconds,
    })

    response.inspect

    if response.code != 200
      raise "#{response.code}"
    end

    accumulator = PreProcessor::WordAccumulator.new

    doc = Nokogiri::HTML5(response.body.to_s)

    doc.css('body>*').each do |node|
      result = prepare_line(node.inner_text.to_s.strip)

      if result.words.empty?
        Rails.logger.warn "Skipping empty node"
        next
      else
        Rails.logger.warn "Set [#{result.hash_s}]: #{result.words_s}"
        accumulator.add_words result.words
      end
    end

    accumulator
  rescue HTTParty::Error => e
    raise e
  end
end

def prepare_line(line)
  result = PreProcessor::LineOfWords.new
  temp = line.gsub(/[\W\d_]+/, ' ').strip.downcase
  if temp.empty?
    result
  end

  result.set(temp)

  result
end
