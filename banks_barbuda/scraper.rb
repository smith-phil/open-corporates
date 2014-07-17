require 'json'
require 'mechanize'

class ScrapeBanks

	def initialize(source_url)
		@source_url = source_url
	end 

	def scrape
		agent = Mechanize.new
		agent.user_agent_alias = 'Mac Safari'

		doc = agent.get(@source_url).parser

		# Skip the first row as it has the headers.
		output = doc.css(".standardText table tr")[1..-1].map do |row|
			row.css("td").map {|r| r.text }
		end

		output
	end

end

url = "http://www.fsrc.gov.ag/banks.asp"

scraper = ScrapeBanks.new(url)

output = scraper.scrape()

output.each do |r| 
	data = {
		number: r[0],
		name: r[1],
		sample_date: Time.now,
		source_url: url
	}
	puts JSON.dump(data)
end 


