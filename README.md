# usage

初めに依存ライブラリをインストール

```
$ sudo gem install bundler
$ bundle install
```

新聞記事をクロール

```
$ bundle exec ruby yomi_crowl.rb
```

クロールしたデータを元にJubatusを学習

```
$ jubaclassifier -f jubaconf.json &> /dev/null &
$ bundle exec ruby jubatus_train.rb
```

サーバを立てる

```
$ bundle exec ruby server.rb
```

あとはブラウザで4567番ポートにアクセスするだけ。
