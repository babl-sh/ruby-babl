module Babl
  class ModuleResponse
    attr_reader :exitcode, :payload_url

    def initialize response
      @stdout_raw = response["Stdout"]
      @stderr_raw = response["Stderr"]
      @exitcode = response["Exitcode"].to_i

      if !response["PayloadUrl"].nil? and response["PayloadUrl"] != ""
        @payload_url = response["PayloadUrl"]
      end
    end

    def stdout allow_fetch = true
      @stdout ||= begin
        if payload_url
          fetch_payload if allow_fetch
        else
          o = Base64.decode64(@stdout_raw)
          @stdout_raw = nil
          o
        end
      end
    end

    def stderr
      @stderr ||= begin
        o = Base64.decode64(@stderr_raw)
        @stderr_raw = nil
        o
      end
    end

    def fetch_payload
      if payload_url
        Net::HTTP.get URI(payload_url)
      end
    end

    def raise_exception_when_unsuccessful!
      if exitcode != 0
        raise ModuleError.new(stdout: stdout(false), stderr: stderr, exitcode: exitcode, payload_url: payload_url)
      end
    end
  end
end
