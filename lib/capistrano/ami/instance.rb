module Capistrano
  module Ami
    module Instance
      include Capistrano::Ami::Credentials

      def intialize
        @client = ::Aws::EC2::Client.new(credentials)
        @ec2 = ::Aws::EC2::Resource.new(client: @client)
      end
      
      def instance(instance_id)
        @ec2.instances(instance_ids: [instance_id]).first
      end

      module_function :credentials
    end
  end
end
