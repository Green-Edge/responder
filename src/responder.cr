require "option_parser"
require "./server"

configfile = ""

parser = OptionParser.parse do |parser|
  parser.banner = "Usage: responder [arguments]"
  parser.on("-c FILE", "--config=FILE", "Configuration YAML file") { |file| configfile = file }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

parser.parse

if configfile == ""
  STDERR.puts parser
  exit(1)
end

responder = Responder.new(configfile)
responder.run
