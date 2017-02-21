# To the extent possible under law, Evan Prodromou has waived all copyright and
# related or neighboring rights to evanp/http-proxy.
# This work is published from: Canada.
# http://creativecommons.org/publicdomain/zero/1.0/

fs = require 'fs'
httpProxy = require 'http-proxy'

config =
  target: process.env.TARGET

if process.env.KEY_FILE
  config.key = fs.readFileSync(process.env.KEY_FILE)
  config.cert = fs.readFileSync(process.env.CERT_FILE)
else if process.env.KEY?
  config.key = process.env.KEY
  config.cert = process.env.CERT

config.port = if process.env.PORT then parseInt(process.env.PORT, 10) else if config.key then 443 else 80

if config.key
  proxy = httpProxy.createProxyServer({target: config.target, ssl: {key: config.key, cert: config.cert}})
else
  proxy = httpProxy.createProxyServer({target: config.target})

# Handle error by blooping out to console

proxy.on 'error', (err) ->
  console.error err

proxy.listen(config.port)
