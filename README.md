#TorVPN Scraper

This is a quickly thrown together script that uses OCR to scrape data from 
torvpn.com. To use it, try `bundle install && ./torvpn-scraper.rb > proxies.txt`.

There will be no output while the program runs, but it should take no longer
than 1 minute to complete.

By default, the script outputs the final results to STDOUT.

**Requires Curl, ImageMagick, and Tesseract**
