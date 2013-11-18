require 'json'
require 'nokogiri'
require 'awesome_print'

require './pull_threads'
require './threads'

testing = false

# Get subset of threads for faster testing
# selected_threads = ThreadList::Threads.each_slice(40).map(&:last)
if testing
	selected_threads = [ThreadList::Threads.first]
	@raw_threads = PullThreads.pull selected_threads
else
	@raw_threads = PullThreads.pull ThreadList::Threads 
end

data = @raw_threads.map do |thread|
	thread_doc = Nokogiri::HTML(thread.html)

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
		list: thread.list,
		thread_id: thread.id,
		title: thread_doc.css('title').text,
		date: posts.empty? ? nil : posts.first[:date],
		num_posts: Integer(stats.first),
		num_authors: Integer(stats.last),
		num_corbitt: posts.select{|p| p[:corbitt]}.count,
		posts: posts
	}
	# puts "#{thread.list}:#{thread.id} #{thread_doc.css('.GFLL15SNXB').text}, #{posts.count}" if hash[:num_posts] != posts.count
	hash
end 

unless testing
	File.open "json/data.json", 'w' do |f|
		f.write data.to_json
	end
end

ap data.first