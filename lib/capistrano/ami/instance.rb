module Capistrano
  module Ami
    module Instance
      include Capistrano::Ami::Credentials

      def ec2
        @ec2 = ::Aws::EC2::Client.new(credentials)
      end

      def deployed_instance
        instance_id = capture "curl -s https://169.254.169.254/latest/meta-data/instance-id"
        ec2.describe_instances(instance_id: instance_id)
      end
    end
  end
end
