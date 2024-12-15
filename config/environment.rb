# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

Rails.logger = Logger.new(STDOUT)
Rails.logger.formatter = proc do | severity, time, progname, msg |
  "#{time}, #{severity}: #{msg} from #{progname} \n"
end
