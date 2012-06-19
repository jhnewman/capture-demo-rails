module CaptureTools::Errors
  def self.raise_from_response(response)
    error = response['error']
    error_description = response['error_description']
    message = "Remote Error: #{response}"
    code = response['code']
    if code == 100
      raise MissingArgumentError.new(response), message
    elsif (200..399).include? code
      raise InvalidArgumentError.new(response), message
    elsif (400..499).include? code
      if code == 414
        raise AccessTokenExpiredError.new(response), message
      else
        raise PermissionError.new(response), message
      end
    else
      raise CaptureRemoteError.new, message
    end
  end


  class CaptureHelperError < StandardError
  end

  class CaptureRemoteError < StandardError
    attr_reader :error, :description, :code, :error_name, :response
    def initialize(response = {})
      @error_name  = response['error']
      @description = response['error_description']
      @error       = @description
      @code        = response['code']
      @response    = response
    end
  end

  class MissingArgumentError < CaptureRemoteError
  end

  class InvalidArgumentError < CaptureRemoteError
  end

  class CannotRemoveAttribute < InvalidArgumentError
  end

  class PermissionError < CaptureRemoteError
  end

  class AccessTokenExpiredError < PermissionError
  end
end
