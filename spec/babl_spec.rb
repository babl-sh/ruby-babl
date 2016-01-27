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
      expect(e.stdout).to eq "this goes to stdout"
      expect(e.stderr).to eq "this goes to stderr\nsome more errors"
      expect(e.exitcode).to be 42
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
    resized = Babl.module!('larskluge/image-resize', in: image_in, env: {WIDTH: 10, HEIGHT: 10, FORMAT: 'jpg'})

    expect(resized.size).to eq image_out.size
  end
end
