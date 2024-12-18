require "httparty"
require "tempfile"
require "poppler"

URL = "http://localhost:3000/media/pdf/nietzsche.pdf"
PATH_S = "./small.pdf"

temp_path = ""

response = HTTParty.get(URL)

if response.code == 200
  Tempfile.create do |file|
    file.write(response.body)
    temp_path = File.absolute_path(file.path.to_s)
    puts "Downloaded and saved #{temp_path}"
    puts "-" * 80
    fi = File.stat(temp_path)
    puts "    File path: #{File.absolute_path(temp_path)}"
    puts "    File size: #{fi.size} bytes"
    puts "    File created at: #{fi.birthtime}"
    puts "    File modified at: #{fi.mtime}"
    puts ""
    puts "Processing PDF file..."

    doc = Poppler::Document.new(temp_path)
    doc.inspect
    puts "-" * 80
    page_count = 1

    doc.each do |page|
      line_count = 1

      page.text.split(/\n/).each do |line|
        line.strip!
        puts "    Line #{page_count}.#{line_count}: #{line}"
        line_count += 1
      end

      page_count += 1
    end
  end
else
  puts "Received HTTP #{response.code} status code"
end
