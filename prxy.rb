require 'webrick' 
require 'webrick/httpproxy' 
require 'set'

CRLF = "\r\n"

class AbloProx < WEBrick::HTTPProxyServer
  
  def initialize(options)
    super
    @blocked = Set.new
    @blocklists = Set.new
    @logging = false
    @log_allowed  = Set.new
    @log_block    = Set.new
  end
  
  def add_blocklist(filename)
    logger.info("loading blocklist #{filename}")
    File.open(filename).each_line do |line|
      block line
    end
    @blocklists.add? filename
  end
  
  def block(host)
    host.strip!
    return if host == nil || host.empty? || host.start_with?('#')
    logger.warn("not adding #{host} as it is already blocked") unless @blocked.add? host
  end
  
  def do_GET(req, res)
    if "ablo.prox" == req.host
      if cmd = req.query['cmd']
        if "reload" == cmd
          logger.info "reloading blocklists"
          reload_blocklists(req, res)
        elsif "log" == cmd
          v = req.query['v'] == '1' ? true : false
          if v
            info          = "start logging"
            @log_allowed  = Set.new
            @log_block    = Set.new
            @logging      = true
          else
            info          = "stop logging"
            @log_allowed  = nil
            @log_block    = nil
            @logging      = false
          end
          logger.info info
          res.status  = 200
          res.body    = info
        elsif "info" == cmd
          res.status = 200
          res.body = "Blocked Hosts:" + CRLF + CRLF
          res.body += @log_block.to_a.join(CRLF)
          res.body += CRLF + CRLF + "Allowed Hosts:" + CRLF + CRLF
          res.body += @log_allowed.to_a.join(CRLF)
        end
      end
      return
    end
        
    if blocked? req.host
      logger.info "BLOCK #{req.host}"
      res.status = 204
      res.keep_alive = false
      @log_block.add? req.host if @logging
    else
      @log_allowed.add? req.host if @logging
      super
    end
  end
  
  def do_CONNECT(req, res)
    host = req.header["host"].first
    if blocked? host
      logger.info "BLOCK #{host}"
      res.status = 204
      res.keep_alive = false
    else
      super
    end
  end
  
  private
  
  def blocked?(host)
    h = host.split('.')
    while !h.empty?
      hostname = h.join '.'
      return true if @blocked.include?(hostname)
      h.shift
    end
    false
  end
  
  def reload_blocklists(req, res)
    @blocked = Set.new
    @blocklists.each do |f|
      add_blocklist f
    end
    res.status = 200
    res.body = "reloaded blocklists: #{@blocklists.to_a.join(', ')}. #{@blocked.count} hosts blocked."
  end
  
end

if ARGV.empty?
  port = 3126
elsif ARGV.size == 1
  port = ARGV[0].to_i
else
  puts 'Usage: prxy.rb [port]'
  exit 1
end

s = AbloProx.new(:Port => port, :AccessLog => [])

# Shutdown functionality
trap("INT"){s.shutdown}

s.add_blocklist 'adservers.txt'
s.add_blocklist 'analytics.txt'
s.add_blocklist 'evil.txt'

s.start
