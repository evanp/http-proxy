#
httpProxy = require 'http-proxy'

config =
  target: process.env.TARGET
  key: process.env.KEY
  cert: process.env.CERT

config.port = if process.env.PORT then parseInt(process.env.PORT, 10) else if config.key then 443 else 80

if config.key
  proxy = httpProxy.createProxyServer({target: config.target, ssl: {key: config.key, cert: config.cert}})
else
  proxy = httpProxy.createProxyServer({target: config.target})

proxy.listen(config.port)
