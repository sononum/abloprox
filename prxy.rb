require 'webrick' 
require 'webrick/httpproxy' 
require 'set'

class AbloProx < WEBrick::HTTPProxyServer
  
  def initialize(options)
    super
    @blocked = Set.new
    @blocklists = Set.new
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
    if "reload.proxy" == req.host
      logger.info "reloading blocklists"
      @blocked = Set.new
      @blocklists.each do |f|
        add_blocklist f
      end
      res.status = 200
      res.body = "reloaded blocklists: #{@blocklists.to_a.join(', ')}. #{@blocked.count} hosts blocked."
      return
    end
      
    if blocked? req.host
      logger.info "BLOCK #{req.host}"
      res.status = 204
      res.keep_alive = false
    else
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
