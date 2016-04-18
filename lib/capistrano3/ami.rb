require "capistrano3/ami/version"

module Capistrano3
  class Ami
    def self.create(base_name)
      @ec2.create_image(name: base_name, no_reboot: true, description: 'created by capistrano3-ami')
    end

    def self.fetch_old_releases(keep_releases)
    end
  end
end

load File.expand_path('../tasks/ami.rake', __FILE__)
