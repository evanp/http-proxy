# To the extent possible under law, Evan Prodromou has waived all copyright and
# related or neighboring rights to evanp/http-proxy.
# This work is published from: Canada.
# http://creativecommons.org/publicdomain/zero/1.0/

http = require 'http'
path = require 'path'
child_process = require 'child_process'

vows = require 'perjury'
assert = vows.assert

debug = require('debug')('evanp-http-proxy:x-forwarded-header-test')
js = JSON.stringify

vows.describe "X-Forwarded-* Headers"
  .addBatch
    "When we start a backend server":
      topic: ->
        server = http.createServer (req, res, next) ->
          res.writeHead 200, {"Content-Type": "text/plain"}
          res.end "Hello, World!"
        server.on "error", (err) =>
          @callback err
        server.listen 2342, =>
          @callback null, server
        undefined
      "it works": (err, server) ->
        assert.ifError err
        assert.isObject server
      teardown: (server) ->
        server.close @callback
        undefined
      "and we start a proxy server":
        topic: ->
          callback = @callback
          env =
            PORT: 1516
            ADDRESS: "localhost"
            TARGET: "http://localhost:2342"

          if process.env.DEBUG?
            env.DEBUG = process.env.DEBUG

          modulePath = path.join(__dirname, "..", "lib", "main.js")
          child = child_process.fork modulePath, [], {env: env, silent: true}

          child.once "error", (err) ->
            callback err

          child.stderr.on "data", (data) ->
            str = data.toString('utf8')
            process.stderr.write "SERVER ERROR: #{str}\n"

          child.stdout.on "data", (data) ->
            str = data.toString('utf8')
            if str.match "Server listening"
              callback null, child
            else if env.SILENT != "true"
              process.stdout.write "SERVER: #{str}\n"

          undefined
        'it works': (err, child) ->
          assert.ifError err
          assert.isObject child
        'teardown': (child) ->
          child.kill()
        'and we make a request to the proxy':
          topic: (child, server) ->
            server.on 'request', (req, res) =>
              @callback null, req.headers
            http.get "http://localhost:1516/helloworld"
            undefined
          "it works": (err, headers) ->
            assert.ifError err
            assert.isObject headers
            debug js headers
            assert.includes headers, "x-forwarded-host"
            assert.includes headers, "x-forwarded-for"
            assert.includes headers, "x-forwarded-proto"
            assert.includes headers, "x-forwarded-port"
  .export module
