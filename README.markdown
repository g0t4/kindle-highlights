kindle-highlights
============

*Get your Kindle highlights via Amazon's Kindle site*

There's currently no Kindle API, so [https://github.com/speric](https://github.com/speric) built a backup and I modified it [https://github.com/g0t4](https://github.com/g0t4)

**Required gems**

* Mechanize

**The workflow**

- Login
- Scrape books from "Your Books"
- Recursively scrape comments from paginated json API
- Save each book by ASIN with book details and items

I forked this because the original version pulled from "Your Highlights" which is now a page with infinite scroll.  The backup was only pulling from the last book you interacted with as far as I could tell.

**Use Cases**

I modified this to not be a gem but to just be a reusable script that you can run via a Rakefile, this way it's much easier to modify the source code to suit your needs.

- `rake backup`
	- backup everything
	- add amazon.yaml to root of project with email, password, and save_location
- `rake backup_one`
	- backup just one book by ASIN
	- setup amazon.yaml as above and add backup_one with the ASIN of the book you want to backup
- `rake test_parse_book`
	- this is for testing what we scrape about the book (title, author, asin)
	- setup
		- download [https://kindle.amazon.com/your_reading](https://kindle.amazon.com/your_reading) source 
		- save to "your_reading.html" in root of project
- `rake test_save_book`
	- this is for testing creating the saved file we create per book
	- setup	
		- download [https://kindle.amazon.com/kcw/highlights?asin=#{asin}&cursor=#{start_index}&count=#{@page_size}](https://kindle.amazon.com/kcw/highlights?asin=#{asin}&cursor=#{start_index}&count=#{@page_size})
		- replace asin, start_index and page_size with the values you want to test
		- save to "highlights.json"