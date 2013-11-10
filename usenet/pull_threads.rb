require 'fileutils'
require 'pathname'
require 'phantomjs'
require './threads'

class PullThreads
  def self.pull thread_list
    total = thread_list.size
    thread_list.each_with_index.map do |thread, index|
      puts "Downloading thread #{thread} (#{index+1}/#{total})"
      list = thread.split('/')[-3]
      id = thread.split('/')[-2..-1].join("-")

      FileUtils.mkdir_p "raw/#{list}"
      path = "raw/#{list}/#{id}.html"

      html = nil
      if Pathname.new(path).exist?
        File.open(path) do |f|
          html = f.read
        end
      else
        html = Phantomjs.run("./pull_site.js", thread)
        File.open(path, 'w') do |f|
          f.write html
        end
      end
      html
    end
  end
end

PullThreads.pull ThreadList::Threads