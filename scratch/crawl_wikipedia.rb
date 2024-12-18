require 'spidr'

url_map = Hash.new { |hash,key| hash[key] = [] }

Spidr.site('https://en.wikipedia.org/', robots: true) do |spider|
  spider.every_link do |origin,dest|
    puts "- #{origin} -> #{dest}"
    url_map[dest] << origin
  end
end

# pp url_map
