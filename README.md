evanp/http-proxy
================

This is a simple HTTP proxy. Most of the heavy lifting is done by the
nodejitsu/http-proxy package. The value here is that you can configure the
process using environment variables, so it's easy to drop into a
docker-compose.yml.

The program will listen on a configured port, and forward all HTTP traffic to a
remote proxy.

License
-------

http://creativecommons.org/publicdomain/zero/1.0/

Configuration
-------------

* ***KEY*** The SSL key to use, if you're supporting HTTPS. Not a filename; the
  actual key itself.
* ***CERT*** The SSL cert, if it's HTTPS. Not a filename; the certificate
  itself.
* ***KEY_FILE*** The SSL key to use, if you're supporting HTTPS. A filename.
* ***CERT_FILE*** The SSL cert, if it's HTTPS. A filename.
* ***PORT*** The port to listen on. Defaults to 80 if there's no KEY, or 443 if
  there is one.
* ***TARGET*** The target URL. Every request will be forwarded to this URL.
