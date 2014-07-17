require 'json'
require 'pdf/reader'
require 'open-uri'


class CaymanScraper

	def initialize(source_url, start_flag, end_flag)
		@source_url = source_url
		@start_flag = start_flag
		@end_flag = end_flag
	end 

	# This method retuns lines of text from a PDF located on the web
	# as an array for strings. One array element per PDF line.
	def get_lines()

		io = open(@source_url)
		lines = Array.new()
		PDF::Reader.open(io) do |reader|
			reader.pages.each do |page|
				lines.concat(page.text.lines())
			end
		end

		#strip out surrounding whitespace and tabs
		lines.collect(&:strip!)
		lines.collect{|e| e.gsub! /\t/, ''}
		
		lines 

	end 

	def scrape()

		lines = get_lines()
		
		# This gets the table lines without the rest of the 
		# PDF's information. Once we have them we can 
		start_idx = lines.index(@start_flag)  + 1 
		e = lines.each_with_index.select {|item, index| item =~ /^#{@end_flag}/} 
		finish_idx = e.map! {|i, idx| idx}
		finish = finish_idx[0] - start_idx
		d = lines.slice(start_idx, finish)
		# remove any blank lines
		d.delete_if(&:empty?)

		d
	end 
end 

id = "3807"
start_flag = "Nominee (Trust)" #text flag that tells scraper where to start scraping from
end_flag = "Total Nominee" #text flag that tells scraper where to stop

url = "http://www.cimoney.com.ky/WorkArea/DownloadAsset.aspx?id=#{id}"

scraper = CaymanScraper.new(url, start_flag, end_flag)
d = scraper.scrape()

# now we have each line, process each record
d.each do |line|
	l = line.split(/Nominee \(/)[0]
	i = l.index(" ").to_i
	data = {
		number: l[0,i],
		name: l[i..-1].strip!,
		sample_date: Time.now,
		source_url: url
	}
	puts JSON.dump(data)
end

