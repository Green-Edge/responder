require "json"
require "log"
require "spec"
require "../src/server"

Log.setup(:debug)

configfile = "example.yml"

describe "responder" do
  context "standard commands" do
    it "should respond to a simple 'PING' command" do
      responder = Responder.new(configfile)

      responder.process("PING", [] of String).should eq("PONG")
    end

    it "should process to a standard 'HELLO' command" do
      responder = Responder.new(configfile)

      result = responder.process("HELLO", ["world"])
      JSON.parse(result)["success"].should eq(true)
      JSON.parse(result)["result"].should eq("HELLO world")
    end
  end

  context "bad commands" do
    it "should respond with an error" do
      responder = Responder.new(configfile)

      result = responder.process("unknown", [] of String)
      JSON.parse(result)["success"].should eq(false)
      JSON.parse(result)["error"].should eq("unknown operation 'unknown'")
    end
  end
end
