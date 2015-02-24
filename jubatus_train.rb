#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

host = "127.0.0.1"
port = 9199
name = "test"

require 'jubatus/classifier/client'
require 'json'

client = Jubatus::Classifier::Client::Classifier.new(host, port, name)
train_data = JSON.parse File.open("dataset.json").read
datasets = train_data.map{|m|
  [
   m["label"],
   Jubatus::Common::Datum.new("text" => m['text'])
  ]
}
client.train(datasets)


result = client.classify([Jubatus::Common::Datum.new("text" => "米大リーグ、ヤンキースの田中が２０日、キャンプインを翌日に控えて記者会見を行い、「去年よりコンディションは良い」と自主トレーニングでの順調な調整ぶりを語った。米メディアからは昨季痛めた右肘の状態について質問が相次いだが、「普通にシーズンを送れると思っている」と強調した。田中は、この日もキャッチボールやダッシュなど軽めのメニューで体を動かした。")])[0]

result.each{|d|
  puts "label:#{d.label} with #{d.score}"
}
