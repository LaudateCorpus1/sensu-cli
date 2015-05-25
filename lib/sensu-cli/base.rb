module SensuCli
  class Base
    attr_accessor :cli
    def setup
      self.cli = Cli.new.global
      settings
      if cli[:command] == 'socket'
        socket
      else
        api_path(cli)
        make_call
      end
    end

    def socket
      socket = SensuCli::Client::Socket.new
      socket.format_message(cli[:fields])
      socket.send_udp_message
    end

    def settings
      directory = "#{Dir.home}/.sensu"
      file = "#{directory}/settings.rb"
      alt = '/etc/sensu/sensu-cli/settings.rb'
      settings = Settings.new
      if settings.file?(file)
        SensuCli::Config.from_file(file)
      elsif settings.file?(alt)
        SensuCli::Config.from_file(alt)
      else
        settings.create(directory, file)
      end
      Rainbow.enabled = Config.pretty_colors == false ? false : true
    end

    def api_path(cli)
      p = PathCreator.new
      p.respond_to?(cli[:command]) ? path = p.send(cli[:command], cli) : SensuCli::die(1, 'Something Bad Happened')
      @api = { :path => path[:path], :method => cli[:method], :command => cli[:command], :payload => (path[:payload] || false) }
    end

    def make_call
      opts = {
        :path => @api[:path],
        :method => @api[:method],
        :payload => @api[:payload],
        :host => Config.host,
        :port => Config.port,
        :ssl => Config.ssl || false,
        :user => Config.user || nil,
        :read_timeout => Config.read_timeout || 15,
        :open_timeout => Config.open_timeout || 5,
        :password => Config.password || nil,
        :proxy_address => Config.proxy_address || nil,
        :proxy_port => Config.proxy_port || nil
      }
      api = Api.new
      res = api.request(opts)
      msg = api.response(res.code, res.body, @api[:command])
      msg = Filter.new(cli[:fields][:filter]).process(msg) if cli[:fields][:filter]
      endpoint = @api[:command]
      if res.code != '200'
        SensuCli::die(0)
      elsif cli[:fields][:format] == 'single'
        Pretty.single(msg, endpoint)
      elsif cli[:fields][:format] == 'table'
        fields = nil || cli[:fields][:fields]
        Pretty.table(msg, endpoint, fields)
      elsif cli[:fields][:format] == 'json'
        Pretty.json(msg)
      else
        Pretty.print(msg, endpoint)
      end
      Pretty.count(msg) unless cli[:fields][:format] == 'table' or cli[:fields][:format] == 'json'
    end
  end
end
