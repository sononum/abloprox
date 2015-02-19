#!/bin/sh
#
# https://github.com/mro/abloprox/tree/ablopac/blackholeproxy
# 
# based on
#
# John's No-ADS proxy script
#      http://www.schooner.com/~loverso/no-ads/
#      loverso@schooner.com
#
# Copyright 2015, Marcus Rohrmoser.  All Rights Reserved.
# Copyright 1996-2003, John LoVerso.  All Rights Reserved.
#
#      Permission is given to distribute this file, as long as this
#      copyright message and author notice are not removed, and no
#      monies are exchanged.
#
#      No responsibility is taken for any errors on inaccuracies inherent
#      either to the comments or the code of this program, but if reported
#      to me, then an attempt will be made to fix them.
#

#
# This fakes an HTTP transaction by it just returning a canned response.
#
# Normally, this is run from inetd with this line in inetd.conf
# (remember to "kill -HUP" the inetd process after changing that file)
#
# # no-ads proxy
# 3421 stream tcp nowait nobody /usr/local/lib/www/noproxy noproxy
#
# 3421 is either an arbitrary TCP port number or TCP service name;
# just make sure you use the same value in "no-ads.pac".
#
###############################################################################

SERVER="https://github.com/mro/abloprox/blob/ablopac/blackholeproxy"

# Pick one of the noproxy schemes and use it at the end

###############################################################################
#
# Just deny the connection
#
deny() {
  echo HTTP/1.0 501 No Ads Accepted
  echo ""
}

###############################################################################
#
# Return redirection to "no-ads" image,
# so you can tell when an ad is suppressed.
#
redir() {
  printf '%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n' \
    "HTTP/1.0 301 No Ads Accepted" \
    "Date: Mon, 20 Oct 1997 12:25:47 GMT" \
    "Server: $SERVER" \
    "${1-"Location: http://freebase/~loverso/no-ads.gif"}" \
    ""
}

###############################################################################
#
# Return an image.  Returns either noproxy.clear.gif or noproxy.noads.gif.
#
# Netscape 4.0 bug with <script SRC="http://adforce.imgis.com/...">
# causes crash when returning an image.  This may have been fixed since.
#
# Netscape bug with <layer> causes such references to use the embedded
# link as a title.  alta vista uses <layer> for ads.  damn.
#
image() {
  # result="404 No Ads Accepted"
  result="200 No Ads Accepted"
  image=noads.png size=2904
  # image=clear.png size=2767
  printf '%s\r\n' \
    "HTTP/1.0 $result" \
    "Date: Mon, 12 Nov 2001 12:25:47 GMT" \
    "Server: $SERVER" \
    "Last-Modified: Mon, 20 Oct 1997 12:25:47 GMT" \
    "Expires: Mon, 20 Oct 2040 20:20:20 GMT" \
    "Content-Length: $size" \
    "Content-Type: image/png" \
    "" |
  cat - $0.$image
}

###############################################################################
#
empty() {
  result="418 No Ads Accepted"
#  result="404 No Ads Accepted"
#  result="200 No Ads Accepted"
  r=${1-' '}
  size=${1:+${#r}}
  size=${size:-"1"}
  printf '%s\r\n' \
    "HTTP/1.0 $result" \
    "Date: Mon, 12 Nov 2001 12:25:47 GMT" \
    "Server: $SERVER" \
    "Last-Modified: Mon, 20 Oct 1997 12:25:47 GMT" \
    "Expires: Mon, 20 Oct 2040 20:20:20 GMT" \
    "Content-Length: $size" \
    "Content-Type: text/plain" \
    "" "$r"
}

###############################################################################
#
fourohfour() {
  result="404 No Ads Accepted"
  printf '%s\r\n' \
    "HTTP/1.0 $result" \
    "Date: Mon, 12 Nov 2001 12:25:47 GMT" \
    "Server: $SERVER" \
    "" 
}


###############################################################################
#
# If we got this, no-ads sent it to the blackhole
control() {
  result="200 OK"
  printf '%s\r\n' \
    "HTTP/1.0 $result" \
    "Server: $SERVER" \
    "Content-Type: text/plain" \
    "" \
    "Successful: $url" \
    "" \
    "From $(basename "$0")" \
    "running from $(dirname "$0")" \
    "running on $(hostname)" \
    "as user $(id -un)" \
    "at $(date)" \
    ""
}

###############################################################################

# quaff HTTP request + 1st line of headers
read meth url http
read h f

# Gack!  This is needed on Linux, as Linux TCP does not handle half
# open TCP connections (WHY!?) and will reset a connection with unread data
cat <&0 > /dev/null &
catpid=$!
# close stdin
exec <&-

cd "$(dirname "$0")"

#####
#
# Choose one of deny, redir, image, or fourohfour
# or... use the case statement to selective return a response
#
###deny
###redir
###image
###fourohfour

case "$url" in
http://no-ads.int/*)
  control
  ;;
*.js)
  empty '//'
  ;;
*)
  image
  ;;
esac

# close (for broken Linux)
exec >&- 2>&-
kill $catpid

exit 0
