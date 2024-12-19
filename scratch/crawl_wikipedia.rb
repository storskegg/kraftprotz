require 'spidr'

# url_wikipedia = 'https://en.wikipedia.org/wiki/Main_Page'
url_wikipedia = 'http://localhost:3000'

links_count = 0
page_count = 0
pdf_count = 0

user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:134.0) Gecko/20100101 Firefox/134.0"
filter_wikipedia = /(:|\.php|^\/w\/)/

begin
  puts "Crawling Wikipedia..."
  puts "-"*80

  Spidr.site(
    url_wikipedia,
    robots: true,
    user_agent: user_agent,
    strip_query: true,
    # ignore_links: [filter_wikipedia],
  ) do |spider|
    puts "[BEGIN]"

    spider.every_url do |url|
      u = URI.parse(url)
      if filter_wikipedia.match?(u.path)
        puts "[SKIP_MATCH] Skipping link: #{url}"
        spider.skip_link!
      else
        links_count += 1
        puts "[ACCEPT_MATCH|#{links_count}] #{url}"
      end
    end

    spider.every_html_page do |page|
      page_count += 1
      puts '=' * 25 + "[PAGE|#{page_count}]" + '=' * 25

      if page.headers['content-language'].nil?
        puts "[SKIP_LANG|#{page_count}] Absent Content-Language header for page: #{page.url}"
        return
      end

      lang = page.headers['content-language'].join(' ').downcase

      if lang.include? 'en'
        puts "[ACCEPT_LANG|#{page_count}]", "    '#{page.body[0..80].gsub(/\n+/, ' ').strip}...'"
      else
        puts "[SKIP_LANG|#{page_count}] Skipping non-English page: #{page.url}"
        puts "    Content-Language: '#{page.headers['content-language'].join(' ').downcase}'"
        spider.skip_page!
      end

      spider.pause! unless page_count < 20
    end

    spider.every_pdf_page do |page|
      pdf_count += 1
      puts '=' * 35 + "[PDF|#{pdf_count}]" + '=' * 15

      puts "[ACCEPT_PDF|#{pdf_count}]", "    '#{page.body[0..80].gsub(/\n+/, ' ').strip}...'"

      spider.pause! unless pdf_count < 2
    end
  end
rescue Spidr::Error => e
  puts "An error occurred during crawling: #{e.message}"
  exit 2
rescue StandardError => e
  puts "An error occurred: #{e.message}"
  exit 1
end
