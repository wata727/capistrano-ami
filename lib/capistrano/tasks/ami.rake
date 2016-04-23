namespace :ami do
  task :create do
    p "Createing AMI...."
    ami = Capistrano::Ami.create(fetch(:base_ami_name, 'capistrano-ami'))
    p "Created AMI: #{ami.id}"
  end

  task :delete_old_releases do
    p "Delete old releases...."
    Capistrano::Ami.fetch_old_releases(fetch(:ami_keep_releases, 5)) do |ami|
      ami.deregister
      ami[:block_device_mapping].each do |device|
        @ec2.delete_snapshot(snapshot_id: device[:ebs][:snapshot_id])
      end
      p "Deleted AMI: #{ami.id}"
    end
    p "Deleted AMIs"
  end
end

after 'deploy', 'ami:create'
after 'ami:create', 'ami:delete_old_releases'
