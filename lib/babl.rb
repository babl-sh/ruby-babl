require 'quartz'
require 'base64'
require 'net/http'


module Babl
  class UnknownModuleError < StandardError; end
  class ModuleNameFormatIncorrectError < StandardError; end

  class ModuleError < StandardError
    attr_reader :stdout, :stderr, :exitcode

    def initialize opts = {}
      @stdout = opts[:stdout]
      @stderr = opts[:stderr]
      @exitcode = opts[:exitcode]
    end

    def to_s
      "Module execution failed with exitcode #{exitcode}. Stderr:\n#{stderr}"
    end
  end

  def self.fetch_payload raw_response
    url = raw_response['PayloadUrl']
    raw_response['Stdout'] = Base64.strict_encode64(Net::HTTP.get URI(url)) if url != ''
    raw_response
  end

  def self.bin_path
    system = `which babl-rpc`.strip
    if system.empty?
      bin = 'babl-rpc_'
      bin += "linux_amd64" if RUBY_PLATFORM =~ /linux/
      bin += "darwin_amd64" if RUBY_PLATFORM =~ /darwin/
      File.expand_path("../../bin/#{bin}", __FILE__)
    else
      STDERR.puts "Warn: Using locally installed binary '#{system}'"
      system
    end
  end

  def self.version
    `#{bin_path} -version`.strip
  end

  def self.client
    @client ||= Quartz::Client.new(bin_path: bin_path)
  end

  def self.module! name, opts = {}
    res = fetch_payload(call! name, opts)
    stdout = Base64.decode64(res["Stdout"])
    exitcode = res['Exitcode']
    if exitcode != 0
      stderr = Base64.decode64(res["Stderr"])
      raise ModuleError.new(stdout: stdout, stderr: stderr, exitcode: exitcode)
    end
    stdout
  end

  def self.call! name, opts = {}
    params = {'Name' => name}
    if opts[:in]
      params['Stdin'] = Base64.encode64(opts[:in])
    end
    if opts[:env]
      params['Env'] = opts[:env].inject({}) { |h, (k,v)| h[k.to_s] = v.to_s; h }
    end
    if opts[:endpoint]
      params['BablEndpoint'] = opts[:endpoint]
    end
    begin
      res = client[:babl].call('Module', params)
    rescue Quartz::ResponseError => e
      if e.message == 'babl-rpc: module name format incorrect'
        raise ModuleNameFormatIncorrectError.new('Module Name Format Incorrect')
      else
        raise
      end
    end
    res
  end
end
