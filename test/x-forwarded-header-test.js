/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// To the extent possible under law, Evan Prodromou has waived all copyright and
// related or neighboring rights to evanp/http-proxy.
// This work is published from: Canada.
// http://creativecommons.org/publicdomain/zero/1.0/

const http = require('http')
const path = require('path')
const {fork} = require('child_process')

const vows = require('perjury')
const { assert } = vows

const debug = require('debug')('evanp-http-proxy:x-forwarded-header-test')
const js = JSON.stringify

vows.describe('X-Forwarded-* Headers')
  .addBatch({
    'When we start a backend server': {
      topic () {
        const server = http.createServer((req, res, next) => {
          res.writeHead(200, {'Content-Type': 'text/plain'})
          return res.end('Hello, World!')
        })
        server.on('error', err => {
          return this.callback(err)
        })
        server.listen(2342, () => {
          return this.callback(null, server)
        })
        return undefined
      },
      'it works' (err, server) {
        assert.ifError(err)
        return assert.isObject(server)
      },
      teardown (server) {
        server.close(this.callback)
        return undefined
      },
      'and we start a proxy server': {
        topic () {
          const { callback } = this
          const env = {
            PORT: 1516,
            ADDRESS: 'localhost',
            TARGET: 'http://localhost:2342'
          }

          if (process.env.DEBUG != null) {
            env.DEBUG = process.env.DEBUG
          }

          const modulePath = path.join(__dirname, '..', 'lib', 'main.js')
          const child = fork(modulePath, [], {env, silent: true})

          child.once('error', err => callback(err))

          child.stderr.on('data', (data) => {
            const str = data.toString('utf8')
            return process.stderr.write(`SERVER ERROR: ${str}\n`)
          })

          child.stdout.on('data', (data) => {
            const str = data.toString('utf8')
            if (str.match('Server listening')) {
              return callback(null, child)
            } else if (env.SILENT !== 'true') {
              return process.stdout.write(`SERVER: ${str}\n`)
            }
          })

          return undefined
        },
        'it works' (err, child) {
          assert.ifError(err)
          return assert.isObject(child)
        },
        'teardown' (child) {
          return child.kill()
        },
        'and we make a request to the proxy': {
          topic (child, server) {
            server.on('request', (req, res) => {
              return this.callback(null, req.headers)
            })
            http.get('http://localhost:1516/helloworld')
            return undefined
          },
          'it works' (err, headers) {
            assert.ifError(err)
            assert.isObject(headers)
            debug(js(headers))
            assert.includes(headers, 'x-forwarded-host')
            assert.includes(headers, 'x-forwarded-for')
            assert.includes(headers, 'x-forwarded-proto')
            return assert.includes(headers, 'x-forwarded-port')
          }
        }
      }
    }}).export(module)
