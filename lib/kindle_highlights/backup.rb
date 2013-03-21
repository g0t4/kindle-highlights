class KindleHighlightBackup

  def initialize(email_address, password, save_location)
    @page_size = 100
    @email_address = email_address
    @password = password
    @save_location = save_location
  end

  def backup
    login()
    books_by_asin = scrape_books()
    scrape_highlights(books_by_asin)
  end

  def backupOne(asin)
    login()
    books_by_asin = scrape_books().keep_if { |a| a == asin }
    scrape_highlights(books_by_asin)
  end

  def login()
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Windows Mozilla'
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    page = @agent.get('https://kindle.amazon.com/your_reading')
    @amazon_form = page.form('signIn')
    @amazon_form.email = @email_address
    @amazon_form.password = @password
    @signin_submission = @agent.submit(@amazon_form)
  end

  def scrape_books
    books_page = @agent.click(@signin_submission.link_with(:text => /Your Books/))
    return KindleHighlightBackup::KindleParser.parseBooks(books_page.body)
  end

  def scrape_highlights(books_by_asin)
    books_by_asin.each do |asin, book|
      begin
        items = get_items(asin, 0)
        KindleHighlightBackup.save(book, items, @save_location)
      rescue
        puts 'Error getting comments for asin: ' + asin
      end
    end
  end

  def get_items(asin, start_index)
    puts "Fetching @ #{start_index} for asin #{asin}"
    highlights_json = @agent.get("https://kindle.amazon.com/kcw/highlights?asin=#{asin}&cursor=#{start_index}&count=#{@page_size}")
    items = JSON.parse(highlights_json.body)['items']
    puts "Rx #{items.count} records"
    if items.count < @page_size - 1 #Amazon has a bug where it sometimes won't return the page_size but one less... when you use 100 as a page size :(
      return items
    else
      remainder = get_items(asin, start_index + items.count)
      return items.concat(remainder)
    end
  end

  def self.save(book, items, save_location)
    file_path = File.join(save_location, "#{book.asin}.json")
    if items.nil? || items.count == 0
      File.delete(file_path) if File.exists?(file_path)
      return
    end

    data = {
        book: {
            asin: book.asin,
            title: book.title,
            author: book.author
        },
        item_count: items.count,
        items: items
    }
    json = JSON.pretty_generate(data)
    File.open(file_path, 'w') { |f| f.write(json) }

  end

end
