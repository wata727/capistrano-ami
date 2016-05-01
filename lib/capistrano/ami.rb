require 'date'
require "aws-sdk"
require "capistrano/ami/credentials"
require "capistrano/ami/instance"
require "capistrano/ami/version"

module Capistrano
  module Ami
    include Capistrano::Ami::Credentials
    include Capistrano::Ami::Instance

    def self.create(instance_id, base_name)
      image = instance(instance_id, credentials).create_image(name: base_name + '_' + Time.now.to_i.to_s, no_reboot: true, description: 'created by capistrano-ami')
      image.create_tags(tags: [{key: 'created_by', value: 'capistrano-ami'}])
      @client.wait_until(:image_available, image_ids: [image.id])
      image
    end

    def self.fetch_old_releases(keep_releases)
      images = @ec2.images(owners: ['self'], filters: [{name: 'tag:created_by', values: ['capistrano-ami']}])
      images = images.sort { |a,b| b.creation_date <=> a.creation_date }
      images[keep_releases, images.length]
    end

    def self.delete_snapshot(options)
      @client.delete_snapshot(options)
    end

    module_function :instance
    module_function :credentials
  end
end

load File.expand_path('../tasks/ami.rake', __FILE__)
