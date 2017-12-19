// To the extent possible under law, Evan Prodromou has waived all copyright and
// related or neighboring rights to evanp/http-proxy.
// This work is published from: Canada.
// http://creativecommons.org/publicdomain/zero/1.0/

const fs = require('fs');
const httpProxy = require('http-proxy');

const debug = require('debug')('evanp-http-proxy');

const js = JSON.stringify;

const config =
  {target: process.env.TARGET};

if (process.env.KEY_FILE != null) {
  config.key = fs.readFileSync(process.env.KEY_FILE);
  config.cert = fs.readFileSync(process.env.CERT_FILE);
} else if (process.env.KEY != null) {
  config.key = process.env.KEY;
  config.cert = process.env.CERT;
}

if (process.env.PORT != null) {
  config.port = parseInt(process.env.PORT, 10);
} else if (config.key != null) {
  config.port = 443;
} else {
  config.port = 80;
}

if (process.env.ADDRESS != null) {
  config.address = process.env.ADDRESS;
} else {
  config.address = "0.0.0.0";
}

debug(`config = ${js(config)}`);

const props = {
  target: config.target,
  xfwd: true
};

if (config.key != null) {
  props.ssl = {
    key: config.key,
    cert: config.cert
  };
}

debug(`props = ${js(props)}`);

const proxy = httpProxy.createProxyServer(props);

proxy.on('error', function(req, res, err) {

  const message = `${err.name}: ${err.message}`;

  console.log(`${req.url} -> ${message}`);

  if (res) {

    res.writeHead(500, {
      'Content-Length': Buffer.byteLength(message),
      'Content-Type': 'text/plain'
    });

    return res.end(message);
  }
});

proxy.listen(config.port, config.address);

console.log("Server listening");

process.on('SIGTERM', function() {
  console.log("Shutting down...");
  return proxy.close();
});
