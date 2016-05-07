require 'capistrano/all'
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/ami'

require 'webmock/rspec'

def api_mock(action_name)
  stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({ body: /Action=#{action_name}/ }).to_return status: 200, body: File.read(File.join(File.expand_path('../..', __FILE__), 'spec', 'aws_api_response', "#{action_name}.xml"))
end
