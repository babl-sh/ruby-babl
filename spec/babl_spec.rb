require 'spec_helper'

describe Babl do
  it 'has a version number' do
    expect(Babl::VERSION).not_to be nil
  end

  it "checks a module's response" do
    expect(Babl.module "string-append", in: "foo", env: {APPENDIX: "bar"}).to eq "foobar"
  end
end
