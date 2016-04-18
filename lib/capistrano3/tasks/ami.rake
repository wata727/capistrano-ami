namespace :ami do
  task :create do
    p "Createing AMI...."
    ami = Capistrano3::Ami.create(fetch(:base_ami_name, 'capistrano3-ami'))
    p "Created AMI: #{ami.id}"
  end

  task :delete_old_releases do
    p "Delete old releases...."
    Capistrano3::Ami.fetch_old_releases(fetch(:ami_keep_releases, 5)) do |ami|
      ami.delete!
    end
    p "Deleted AMIs"
  end
end

after 'deploy', 'ami:create'
after 'ami:create', 'ami:delete_old_releases'
