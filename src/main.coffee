# To the extent possible under law, Evan Prodromou has waived all copyright and
# related or neighboring rights to evanp/http-proxy.
# This work is published from: Canada.
# http://creativecommons.org/publicdomain/zero/1.0/

fs = require 'fs'
httpProxy = require 'http-proxy'

config =
  target: process.env.TARGET

if process.env.KEY_FILE?
  config.key = fs.readFileSync(process.env.KEY_FILE)
  config.cert = fs.readFileSync(process.env.CERT_FILE)
else if process.env.KEY?
  config.key = process.env.KEY
  config.cert = process.env.CERT

if process.env.PORT?
  config.port = parseInt(process.env.PORT, 10)
else if config.key?
  config.port = 443
else
  config.port = 80

if process.env.ADDRESS?
  config.address = process.env.ADDRESS
else
  config.address = "0.0.0.0"

props =
  target: config.target

if config.key?
  props.ssl =
    key: config.key
    cert: config.cert

proxy = httpProxy.createProxyServer props

proxy.on 'error', (req, res, err) ->

  message = "#{err.name}: #{err.message}"

  console.log "#{req.url} -> #{message}"

  if res?

    res.writeHead 500,
      'Content-Length': Buffer.byteLength(message)
      'Content-Type': 'text/plain'

    res.end message

proxy.listen config.port, config.address

process.on 'SIGTERM', ->
  console.log "Shutting down..."
  proxy.close()
