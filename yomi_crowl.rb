require 'nokogiri'
require 'pp'
require 'json'
require 'jubatus/classifier/client'

LABELS = ["politics", "election", "national", "economy", "world", "sports", "science", "eco", "culture"]
BASE_URL = "http://www.yomiuri.co.jp"
URLS = File.open("urllist.txt", "r").read.split("\n")
CACHE_DIR = "cache"

def get_article(url)
  return nil if url.scan(/(2015.*?.html)/).nil?
  return nil if url.scan(/(2015.*?.html)/)[0].nil?
  name = url.scan(/(2015.*?.html)/)[0][0]
  cache_name = "#{CACHE_DIR}/#{name}"
  data = nil
  if File.exists? cache_name
    return File.open(cache_name, "r").read
  else
    data = `curl #{url} 2> /dev/null`
    File.open("#{CACHE_DIR}/#{name}", "w") {|f| f.write(data)}
    return data
  end
end

def scrape_arcticle(article)
  page = Nokogiri::HTML(article)
  texts = []
  page.xpath("//p").each{|paragraph|
    texts << paragraph.text.chomp
  }
  texts.pop
  texts.pop
  texts.join("")
end

def scrape_urls(article)
  page = Nokogiri::HTML(article)
  links = page.xpath("//a").map{|link|
    link.attributes['href'].value
  }.select{|a|
    a.match(/OYT.*\.html/)
  }.map{|n|
    n.sub(/\?.*/, "\n").chomp
  }
  links
end

targets = URLS
host = "127.0.0.1"
port = 9199
name = "test"

client = Jubatus::Classifier::Client::Classifier.new(host, port, name)



DATASET = "dataset.json"
CONTINUE = "workingset.json"

$targets = URLS
$visited = []
$targets = URLS

if File.exist?(CONTINUE)
  json = JSON.parse(File.read(CONTINUE))
  $visited = json["visited"]
  $targets = json["targets"].concat(URLS)
  $targets -= $visited
else
  $targets = URLS
  $visited = []
end
p $targets
$targets = URLS if $targets.nil?
$visited = URLS if $visited.nil?


if File.exist?(DATASET)
  $dataset = JSON.parse(File.read(DATASET))
else
  $dataset = []
end

def run
  until ($targets.empty?)
    target = $targets.shift
    next if $visited.include? target
    $visited << target
    label = target.scan(/yomiuri.co.jp\/(.*?)\//)[0][0]
    next unless LABELS.include? label
    article = get_article(target)
    next if article.nil?
    $dataset << {
      "label" => label,
      "text" => scrape_arcticle(article)
    }
    $dataset.uniq!
    $targets.concat(scrape_urls(article) - $visited)
    $targets.uniq!
    $targets -= $visited
    puts "urls: #{$targets.size} visited: #{$visited.size}"
  end
end

begin
  run
ensure
  File.open(DATASET, 'w') do |f|
    f.write $dataset.uniq.to_json
  end
  File.open(CONTINUE, 'w') do |f|
    f.write({
              targets: $targets,
              visited: $visited
            }.to_json)
  end
end

#p labeled_datum

