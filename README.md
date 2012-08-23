# Megalith

[![Build Status](https://secure.travis-ci.org/oame/megalith-ruby.png)](http://travis-ci.org/oame/megalith-ruby)

Megalith パーサー for Ruby<br>

## Requirements

* Ruby 1.9.x

## Installation

	gem install megalith

## Usage

	require "megalith"
	
	# 東方創想話(Megalith) をエンドポイントにする
	megalith = Megalith.new("http://coolier.sytes.net:8080/sosowa/ssw_l/")
  
  	# 最新版から最初のSSを持ってくる
	latest_log = megalith.get
	first_novel = latest_log.first.fetch
  
  	# 作品集番号156の1320873807を持ってくる
  	novel = megalith.get(:log => 156, :key => 1320873807)
  	puts novel.text

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
