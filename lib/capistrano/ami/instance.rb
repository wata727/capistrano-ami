module Capistrano
  module Ami
    module Instance
      def instance(instance_id, credentials)
        client = ::Aws::EC2::Client.new(credentials)
        ec2 = ::Aws::EC2::Resource.new(client: client)
        ec2.instances(instance_ids: [instance_id]).first
      end
    end
  end
end
