require 'capistrano/all'
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/ami'

require 'webmock/rspec'

def aws_api_response_mock(api_file_name)
  File.read(File.join(File.expand_path('../..', __FILE__), 'spec', 'aws_api_response', api_file_name))
end
