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
      unless Pathname.new(path).exist?
        puts Phantomjs.run("./pull_site.js", thread, path)
      end
      File.open(path) do |f|
        @html = f.read
      end
      @html
    end
  end
end

PullThreads.pull ThreadList::Threads