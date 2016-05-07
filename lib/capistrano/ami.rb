require 'date'
require 'aws-sdk'
require 'capistrano/ami/credentials'
require 'capistrano/ami/instance'
require 'capistrano/ami/version'

module Capistrano
  module Ami
    extend Capistrano::Ami::Instance

    def self.create(instance_id, base_name)
      image = instance(instance_id).create_image(
        name: ami_name(instance_id, base_name),
        no_reboot: true,
        description: 'created by capistrano-ami'
      )
      image.create_tags(tags: [{ key: 'created_by', value: 'capistrano-ami' }])
      image.create_tags(tags: [{ key: 'base_instance_id', value: instance_id }])
      client.wait_until(:image_available, image_ids: [image.id])
      image
    end

    def self.old_amis(instance_id, keep_amis)
      images = ec2_resource.images(
        owners: ['self'],
        filters: [{
          name: 'tag:created_by',
          values: ['capistrano-ami']
        }, {
          name: 'tag:base_instance_id',
          values: [instance_id]
        }]
      )
      images = images.sort { |a, b| b.creation_date <=> a.creation_date }
      Array(images[keep_amis, images.length])
    end

    def self.delete_snapshot(block_device_mappings)
      block_device_mappings.each do |device|
        client.delete_snapshot(snapshot_id: device[:ebs][:snapshot_id])
      end
    end

    def self.ami_name(instance_id, base_name)
      base_name + '_' + instance_id + '_' + Time.now.to_i.to_s
    end

    private_class_method :ami_name
  end
end

load File.expand_path('../tasks/ami.rake', __FILE__)
