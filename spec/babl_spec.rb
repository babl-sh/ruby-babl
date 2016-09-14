require 'spec_helper'

describe Babl do
  it 'has a version number' do
    expect(Babl.version).not_to be nil
  end

  it "checks a module's response" do
    expect(Babl.module! "larskluge/string-append", in: "foo", env: {APPENDIX: "bar"}).to eq "foobar"
  end

  it "fails with correct exception class" do
    expect {
      Babl.module! "larskluge/test-fail"
    }.to raise_error(Babl::ModuleError)
  end

  it "fails with details" do
    begin
      Babl.module! "larskluge/test-fail"
      fail "No Exception raised."
    rescue Babl::ModuleError => e
      expect(e.stdout).to eq "this goes to stdout\n"
      expect(e.stderr).to eq "this goes to stderr\nsome more errors\n"
      expect(e.exitcode).to be 42
      expect(e.message).to include "Stderr:\nthis goes to stderr\nsome more errors"
    end
  end

  it "sends a very long message" do
    skip
    n = 1963
    expect(Babl.module! "larskluge/string-upcase", in: ("foo" * n)).to eq ("FOO" * n)
  end

  it "resizes an image" do
    skip
    image_in = File.open(File.expand_path("../fixtures/image-resize-in.jpg", __FILE__), "rb") { |f| f.read }
    image_out = File.open(File.expand_path("../fixtures/image-resize-out.jpg", __FILE__), "rb") { |f| f.read }

    expect(image_in.size).to eq 36968
    resized = Babl.module!('larskluge/image-resize', in: image_in, env: {WIDTH: '10', HEIGHT: '10', FORMAT: 'jpg'})

    expect(resized.size).to eq image_out.size
  end

  xit "fails when unknown module is requested" do
    expect {
      Babl.module! 'foooooooo/bbaaaaaaaaaaar'
    }.to raise_error(Babl::UnknownModuleError, /unknown module/i)
  end

  it "fails when a module is requested with an incorrect name format" do
    expect {
      Babl.module! 'foo'
    }.to raise_error(Babl::ModuleNameFormatIncorrectError, /name format incorrect/i)
  end

  it "converts env values to strings to avoid marshal error on Go's end" do
    expect(Babl.module! "larskluge/string-append", in: "foo", env: {APPENDIX: 42}).to eq "foo42"
  end

  describe ".call!" do
    it "checks a basic usage" do
      res = Babl.call! "larskluge/string-upcase", in: "foo"
      expect(res.stdout).to eq "FOO"
    end

    it "uses a payload url as input" do
      res = Babl.call! "larskluge/string-upcase", payload_url: "http://gateway.ipfs.io/ipfs/QmW3J3czdUzxRaaN31Gtu5T1U5br3t631b8AHdvxHdsHWg"
      expect(res.stdout).to eq "BAR"
    end

    it "does not throw an exception when a module call fails with exitcode != 0" do
      res = nil
      expect {
        res = Babl.call! "larskluge/test-fail"
      }.not_to raise_error
      expect(res.exitcode).to be > 0
    end
  end

  describe ".options_to_rpc_parameter" do
    it "copies previous module reponse output to input" do
      raw = "Zm9v\n"
      response = Babl::ModuleResponse.new "Stdout" => raw
      params = Babl.options_to_rpc_parameter "a/b", in: response
      expect(params["Stdin"]).to eq raw
      expect(params["PayloadUrl"]).to be_nil
    end

    it "copies previous module reponse output to input respecting payload_url" do
      url = "http://foo.com"
      response = Babl::ModuleResponse.new "Stdout" => "", "PayloadUrl" => url
      params = Babl.options_to_rpc_parameter "a/b", in: response
      expect(params["PayloadUrl"]).to eq url
    end
  end
end
