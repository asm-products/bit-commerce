# This file is used by Rack-based servers to start the application.

begin
  load File.expand_path('../bin/spring', __FILE__)
rescue LoadError
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
