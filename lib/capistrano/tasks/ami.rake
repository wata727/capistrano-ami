namespace :ami do
  task :create do
    on roles(:all) do |h|
      instance_id = capture "curl -s http://169.254.169.254/latest/meta-data/instance-id"
      info "[capistrano-ami] [#{instance_id}] Createing AMI..."
      ami = Capistrano::Ami.create(instance_id, fetch(:base_ami_name, 'capistrano-ami'))
      info "[capistrano-ami] [#{instance_id}] Created AMI (#{ami.id})"
    end
  end

  task :delete_old_amis do
    on roles(:all) do |h|
      instance_id = capture "curl -s http://169.254.169.254/latest/meta-data/instance-id"
      info "[capistrano-ami] [#{instance_id}] Deleting old AMIs...."
      Capistrano::Ami.old_amis(instance_id, fetch(:keep_amis, 5)).each do |ami|
        ami.deregister
        Capistrano::Ami.delete_snapshot(ami.block_device_mappings)
        info "[capistrano-ami] [#{instance_id}] Deleted AMI (#{ami.id})"
      end
      info "[capistrano-ami] [#{instance_id}] Finished deleting AMIs"
    end
  end
end

after 'deploy', 'ami:create'
after 'ami:create', 'ami:delete_old_amis'
