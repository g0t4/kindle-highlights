class KindleHighlightBackup

  def initialize(email_address, password, save_location)
    login(email_address, password)
    books_by_asin = scrape_books
    scrape_highlights(books_by_asin, save_location)
  end

  def login(email_address, password)
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Windows Mozilla'
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    page = @agent.get("https://kindle.amazon.com/your_reading")
    @amazon_form = page.form('signIn')
    @amazon_form.email = email_address
    @amazon_form.password = password
    @signin_submission = @agent.submit(@amazon_form)
  end

  def scrape_books
    books_page = @agent.click(@signin_submission.link_with(:text => /Your Books/))
    return KindleHighlightBackup::KindleParser.parseBooks(books_page.body)
  end

  def scrape_highlights(books_by_asin, save_location)
    books_by_asin.each do |asin, book|
      begin
        highlights_json = @agent.get("https://kindle.amazon.com/kcw/highlights?asin=#{asin}&cursor=0&count=1000")
        KindleHighlightBackup.save(book, highlights_json.body, save_location)
      rescue
        puts 'Error getting comments for asin: ' + asin
      end
    end
  end

  def self.save(book, highlights_json, save_location)
    highlights = JSON.parse(highlights_json)
    raise 'Pagination not supported in backup yet' if highlights['hasMore']
    highlights['book'] = Hash.new
    highlights['book']['asin'] = book.asin
    highlights['book']['title'] = book.title
    highlights['book']['author'] = book.author
    json = JSON.pretty_generate(highlights)
    file_path = File.join(save_location, "#{book.asin}.json")

    any_items = highlights['items'].count > 0
    if any_items
      File.open(file_path, 'w') { |f| f.write(json) }
    else
      File.delete(file_path) if File.exists?(file_path)
    end

  end

end
