require 'rubygems'
require 'yaml'

$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require 'kindle_highlights'

task :test_parse_book do

  contents = File.read('your_reading.html')
  KindleHighlightBackup::KindleParser.parseBooks(contents)
  .each { |asin, book| puts "#{asin} #{book.author} #{book.title}" }

end

task :test_save_book do
  highlights = File.read('highlights.json')
  book = KindleHighlightBackup::Book.new('FakeAsin', 'FakeTitle', 'FakeAuthor')
  KindleHighlightBackup.save(book, highlights, './')
end

task :backup do
  config = YAML.load_file('amazon.yaml')
  KindleHighlightBackup.new(config['email'], config['password'], config['save_location'])
end