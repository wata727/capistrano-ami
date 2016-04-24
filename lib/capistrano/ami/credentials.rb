module Capistrano
  module Ami
    module Credentials
      include Capistrano::DSL

      def credentials
        @credentials = {
          region: fetch(:aws_region, ENV['AWS_REGION']),
          access_key_id: fetch(:aws_access_key_id, ENV['AWS_ACCESS_KEY_ID']),
          secret_access_key: fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])
        }
      end
    end
  end
end
