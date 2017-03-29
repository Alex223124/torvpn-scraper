#!/usr/bin/env ruby

require 'mini_magick'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'rtesseract'
require 'tempfile'

proxies = []

# Get the HTML
doc = Nokogiri.HTML(open('https://www.torvpn.com/en/proxy-list').read())

# Parse it for image sources
doc.css('tr').each do |row|
  next unless row.css('.fa-check-circle').any?
  proxy = OpenStruct.new
  proxy.port = row.css('td')[2].text.strip
  proxy.type = row.css('td')[4].text.strip.downcase
  proxy.image_url = 'https://www.torvpn.com' + row.css('img[src*="proxypic"]').first.attr('src').strip
  proxies << proxy
end

# Download, process, and store each IP
threads = []
proxies.each do |proxy|
  threads << Thread.new do
    file = Tempfile.new
    file.binmode
    open(proxy.image_url) { |data| file.write(data.read) }
    file.rewind
    image = RTesseract.new(file.path, processor: 'mini_magick')
    proxy.ip = image.to_s.strip
  end
end
threads.each(&:join)

# Test each proxy
good_proxies = []
threads = []
proxies.each do |proxy|
  threads << Thread.new do
    formatted = "#{proxy.type.downcase}://#{proxy.ip}:#{proxy.port}"
    if system("curl -x #{formatted} -m 10 google.com > /dev/null 2>&1")
      good_proxies << formatted
    end
  end
end
threads.each(&:join)

# Output to STDOUT
good_proxies.each { |proxy| puts proxy }
