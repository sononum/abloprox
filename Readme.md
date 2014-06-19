# abloprox

This is my personal home-proxy to filter and clean the web.
It will filter http and https requests to domains given in the blocklists.

## Usage & Installation

Usage: `ruby prxy.rb [port]`

The default port is `3126`

Now, change proxy settings for http and https to 127.0.0.1:3126 (or wherever you bound to)

## Controlling abloprox

abloprox can be controlled via http requests to `http://ablo.prox`:

* Reloading Blocklist: `http://ablo.prox?cmd=reload`
* Start Logging: `http://ablo.prox?cmd=log&v=1`
* Stop Logging: `http://ablo.prox?cmd=log&v=0`
* Log Output: `http://ablo.prox?cmd=info` 

## License

The MIT License (MIT)

(c) 2014 Ulrich Zurucker, http://cmrr.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
