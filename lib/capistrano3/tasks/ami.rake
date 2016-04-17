namespace :ami do
  task :create do
    # do something...
  end
end

after 'deploy', 'ami:create'
