require 'quartz'
require 'base64'


module Babl
  class UnknownModuleError < StandardError; end

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

  def self.bin_path
    system = `which babl-rpc`.strip
    if system.empty?
      bin = 'babl-rpc_'
      bin += "linux_amd64" if RUBY_PLATFORM =~ /linux/
      bin += "darwin_amd64" if RUBY_PLATFORM =~ /darwin/
      File.expand_path("../../bin/#{bin}", __FILE__)
    else
      system
    end
  end

  def self.version
    `#{bin_path} -version`.strip
  end

  def self.client
    STDERR.puts "Using bin '#{bin_path}'"
    @client ||= Quartz::Client.new(bin_path: bin_path)
  end

  def self.module! name, opts = {}
    params = {'Name' => name}
    if opts[:in]
      params['Stdin'] = Base64.encode64(opts[:in]).strip
    end
    if opts[:env]
      params['Env'] = opts[:env].inject({}) { |h, (k,v)| h[k.to_s] = v.to_s; h }
    end
    begin
      res = client[:babl].call('Module', params)
    rescue Quartz::ResponseError => e
      if e.message == 'babl-rpc: unknown module'
        raise UnknownModuleError.new('Unknown Module')
      else
        raise
      end
    end
    stdout = Base64.decode64(res["Stdout"]).strip
    exitcode = res['Exitcode']
    if exitcode != 0
      stderr = Base64.decode64(res["Stderr"]).strip
      raise ModuleError.new(stdout: stdout, stderr: stderr, exitcode: exitcode)
    end
    stdout
  end
end
