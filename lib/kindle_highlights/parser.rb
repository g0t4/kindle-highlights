class KindleHighlightBackup::KindleParser

  def self.parseBooks(html)
    doc = Nokogiri::HTML(html)

    book_asins = doc.xpath("//input[@name='asin']")
    .collect { |b| b.attribute('value').value }
    .uniq { |b| b }

    books = Hash.new
    book_asins.each do |asin|
      title = get_title(asin, doc)
      author = get_author(asin, doc)
      books[asin] = KindleHighlightBackup::Book.new(asin, title, author)
    end
    return books
  end

  def self.get_title(asin, doc)
    titleNode = get_title_node(asin, doc)
    return titleNode.inner_text
  end

  def self.get_title_node(asin, doc)
    titles = doc.search("//td[@class='titleAndAuthor']/a[contains(@href,'#{asin}')]")
    raise 'title not unique for asin: ' + asin if titles.count > 1
    raise 'no title for asin: ' + asin if titles.count == 0
    titleNode = titles[0]
  end

  def self.get_author(asin, doc)
    titleNode = get_title_node(asin, doc)
    authorNode = titleNode.parent.xpath("span[@class='author']")
    raise 'cannot find author' if authorNode.nil?
    return authorNode.inner_text.strip
  end

end

class KindleHighlightBackup::Book

  attr_accessor :asin, :title, :author

  def initialize(asin, title, author)
    @asin = asin
    @title = title
    @author = author
  end

end