require "capistrano/ami/version"

module Capistrano
  module Ami
    include Capistrano::Ami::Instance

    def self.create(base_name)
      image = deployed_instance.create_image(name: base_name, no_reboot: true, description: 'created by capistrano-ami')
      image.create_tags(tags: [{key: 'created_by', value: 'capistrano-ami'}])
      image
    end

    def self.fetch_old_releases(keep_releases)
      images = @ec2.describe_images(owners: ['self'], filters: [{name: 'created_by', value: 'capistrano-ami'}])[:images_set]
      images.sort! { |a,b| b[:creation_date] <=> a[:creation_date] }
      images[keep_releases, images.length]
    end
  end
end

load File.expand_path('../tasks/ami.rake', __FILE__)
