require 'json'
require 'nokogiri'
require 'awesome_print'

require './pull_threads'
require './threads'

testing = false

# Get subset of threads for faster testing
# selected_threads = ThreadList::Threads.each_slice(40).map(&:last)
puts "Pulling threads (Testing: #{testing})"
if testing
	selected_threads = [ThreadList::Threads.first]
	@raw_threads = PullThreads.pull selected_threads
else
	@raw_threads = PullThreads.pull ThreadList::Threads 
end

output = File.open "json/data.json", 'w'

puts "#{@raw_threads.size} threads pulled. Processing."

output_count = 0
@raw_threads.each do |thread|
	thread_doc = Nokogiri::HTML(thread.html)
	begin
		posts = thread_doc.css('.GFLL15SCEB').map do |post|
			summary = {}
			summary[:author] = post.css('._username').text
			summary[:date] = post.css('.GFLL15SABC')[0]["title"]
			summary[:corbitt] = summary[:author] == "Don Corbitt" ? true : false
			summary[:content] = post.css('.GFLL15SJDB')
			summary
		end
		stats = thread_doc.css('.GFLL15SNXB').text.scan /\d+/
		hash = {
			url: thread.url,
			list: thread.list,
			thread_id: thread.id,
			title: thread_doc.css('title').text[0..-17],
			date: posts.empty? ? nil : posts.first[:date],
			num_posts: posts.count,
			num_authors: Integer(stats.last),
			num_corbitt: posts.select{|p| p[:corbitt]}.count,
			posts: posts
		}
		# puts "#{thread.list}:#{thread.id} #{thread_doc.css('.GFLL15SNXB').text}, #{posts.count}" if hash[:num_posts] != posts.count
		if hash[:num_corbitt] > 0
			output.puts hash.to_json
			output_count += 1
		end 
	rescue
		puts "Bad thread"
	end
end

puts "#{output_count} threads successfully parsed"