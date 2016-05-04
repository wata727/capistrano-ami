module Capistrano
  module Ami
    module Credentials
      def credentials(profile_name)
        @credentials ||= ::Aws::SharedCredentials.new(profile_name: profile_name) if profile_name
        @credentials ||= ::Aws::Credentials.new(
          fetch(:aws_access_key_id, ENV['AWS_ACCESS_KEY_ID']),
          fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])
        )
      end
    end
  end
end
