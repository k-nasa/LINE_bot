require 'httpclient'
require 'json'

msg = 'こんにちは'
puts 'Me>' + msg
body = JSON.generate(utt: msg) # {:utt => msg}のこと
clnt = HTTPClient.new
uri = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=3549664a4c676144774c50573564565265784865326964767739705a714a304c307630586b683948354839'
res = clnt.post_content(uri, body, {'Content-Type' => 'application/json'})
my_hash = JSON.parse(res)
puts 'docomo>' + my_hash['utt'].to_s

