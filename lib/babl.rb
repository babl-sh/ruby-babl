require 'quartz'
require 'base64'

require "babl/version"


module Babl

  def self.bin_path
    bin = 'babl-rpc_'
    bin += "linux_amd64" if RUBY_PLATFORM =~ /linux/
    bin += "darwin_amd64" if RUBY_PLATFORM =~ /darwin/
    File.expand_path("../../bin/#{bin}", __FILE__)
  end

  def self.client
    @client ||= Quartz::Client.new(bin_path: bin_path)
  end

  def self.module name, opts = {}
    params = {'Name' => name}
    if opts[:in]
      params['Stdin'] = Base64.encode64(opts[:in])
    end
    if opts[:env]
      params['Env'] = opts[:env].inject({}) { |h, (k,v)| h[k.to_s] = v; h }
    end
    res = client[:babl].call('Module', params)
    Base64.decode64(res["Stdout"])
  end
end
