require "json"
require "log"
require "yaml"
require "resp-server"


class Responder
  Log = ::Log.for(self)

  @config : YAML::Any = YAML.parse "{}"

  def initialize(configfile : String)
    @configfile = configfile

    reload_config()

    @port = @config["port"]? ? @config["port"].as_i : 6379
    @host = @config["host"]? ? @config["host"].as_s : "127.0.0.1"
  end

  def reload_config
    begin
      @config = File.open(@configfile) do |file|
        YAML.parse(file)
      end
    rescue File::NotFoundError
      Log.error { "cannot read file: #{@configfile}" }
      exit(1)
    rescue ex : YAML::ParseException
      raise("#{@configfile} contains invalid YAML: #{ex}")
    end

    Log.debug {"Config loaded from #{@configfile}, rules loaded: #{@config["rules"].size}"}
  end

  def run
    Log.info {"Listening on #{@host}:#{@port}..."}
    server = RESP::Server.new(@host, @port)
    server.listen do |conn|
      operation, args = conn.parse
      conn.send_string process(operation, args)
    end
  end

  def process(operation, args)
    reload_config()

    Log.debug {"#{self.class}: processing #{operation} with args: #{args}"}
    operation =
      "#{operation}".strip

    opstring = opstringify(operation, args)

    if opstring.empty?
      return ""
    end

    matches = @config["rules"].as_a.map do |rule|
      /#{rule["match"]}/.match(opstring) ? rule : nil
    end

    rule = matches.reject(nil).first?
    Log.debug {"#{self.class}: found rule #{rule}"}

    if rule.nil?
      error = "unknown operation: #{opstring}"
      Log.error {"#{self.class}: #{error}"}
      return {
        "success" => false,
        "error" => error
      }.to_json
    end

    response = rule["response"].to_json

    if md = opstring.match(/#{rule["match"]}/)
      md.to_a.each_with_index do |val, i|
        response = response.gsub("$#{i}", val)
      end
    end

    if rule["wait"]?
      sleep(Time::Span.new(nanoseconds: rule["wait"].as_i * 1_000))
    end

    response
  end

  private def opstringify(operation, args)
    case args
    when Array(String)
      ("#{operation} " + args.join(" ")).strip
    when String
      "#{operation} #{args}".strip
    else
      operation.strip
    end
  end
end
