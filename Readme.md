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


## Client configuration

### Provide a PAC file

Drop a
[PAC file](https://en.wikipedia.org/wiki/Proxy_Auto-Config#The_PAC_File)
named `example.pac` similar the one below somewhere on a webserver and
enter it's URL into the OS/browser proxy configuration:

    // inspired by
    // - https://de.wikipedia.org/wiki/Proxy_Auto-Config#Die_PAC-Datei
    // - http://www.proxypacfiles.com/proxypac/index.php?option=com_content&view=article&id=58&Itemid=87
    function FindProxyForURL(url, host) {
      if (shExpMatch(host,"*.fritz.box")) return "DIRECT";        # don't proxy local network
      if (shExpMatch(host,"*.local")) return "DIRECT";            # don't proxy local network
      if (shExpMatch(host,"*.akamaistream.net")) return "DIRECT"; # don't proxy streams
      return "PROXY <hostname_of_the_proxy>:3126"; // Default return condition is the proxy on host <hostname_of_the_proxy>.
    }


### Auto-configuration

1. ensure there's a host 'wpad' in the current network, see
  - https://en.wikipedia.org/wiki/Web_Proxy_Autodiscovery_Protocol#Context
  - e.g. via [FritzBox hostname panel](http://fritz.box/net/network_user_devices.lua)
2. have a http webserver running on that host, e.g. [lighttpd](https://packages.debian.org/wheezy/lighttpd)
3. ensure http://wpad/wpad.dat contains a PAC file similar the one above.


## Launch in background

### Debian GNU/Linux

Preliminaries [daemon](https://packages.debian.org/wheezy/daemon):

    $ apt-get install deamon

[Crontab](https://packages.debian.org/wheezy/cron)

    @reboot daemon --name abloprox --chdir=/srv/abloprox --stdout=prxy.log --stderr=prxy.log -- ruby prxy.rb

Check status

    $ daemon --verbose --name abloprox --running


## License

The MIT License (MIT)

(c) 2014 Ulrich Zurucker, http://cmrr.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
