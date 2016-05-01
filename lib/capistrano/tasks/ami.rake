namespace :ami do
  task :create do
    on roles(:all) do |h|
      instance_id = capture "curl -s http://169.254.169.254/latest/meta-data/instance-id"
      info "Createing AMI for #{instance_id} ..."
      ami = Capistrano::Ami.create(instance_id, fetch(:base_ami_name, 'capistrano-ami'))
      info "Created AMI: #{ami.id}"
    end
  end

  task :delete_old_releases do
    on roles(:all) do |h|
      info "Delete old releases...."
      Capistrano::Ami.fetch_old_releases(fetch(:ami_keep_releases, 5)).each do |ami|
        ami.deregister
        ami.block_device_mappings.each do |device|
          Capistrano::Ami.delete_snapshot(snapshot_id: device[:ebs][:snapshot_id])
        end
        info "Deleted AMI: #{ami.id}"
      end
      info "Deleted AMIs"
    end
  end
end

after 'deploy', 'ami:create'
after 'ami:create', 'ami:delete_old_releases'
