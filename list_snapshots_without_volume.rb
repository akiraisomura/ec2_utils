# frozen_string_literal: true

require 'aws-sdk'
require 'active_support/all'

def main
  unused_snapshots = list_unused_snapshots
  p unused_snapshots.map { |s| "id: #{s.snapshot_id}, v-size: #{s.volume_size}, start_time: #{s.start_time}" }
end

def list_unused_snapshots
  snapshots_without_volume = list_snapshots_without_volume

  list_snapshots_without_ami(snapshots_without_volume)
end

def slice_ami_ids_from(snapshots)
  snapshots.map { |s| slice_ami_id_from(s) }.compact
end

def slice_ami_id_from(snapshot)
  ami_id = snapshot.description.match(/((ami-.*?)\s|ami-.*)/)
  ami_id[1].strip if ami_id
end

def list_snapshots_without_volume
  snapshots = client.describe_snapshots(owner_ids: ["self"]).snapshots
  all_volume_ids = client.describe_volumes.volumes.map(&:volume_id)
  snapshots.reject { |s| s.volume_id.in?(all_volume_ids) }
end

def list_snapshots_without_ami(snapshots)
  image_ids = slice_ami_ids_from(snapshots)
  nonexistent_image_ids = select_nonexistent_image_ids(image_ids)
  snapshots.select do |snapshot|
    ami_id = slice_ami_id_from(snapshot)
    ami_id.in?(nonexistent_image_ids)
  end
end

def select_nonexistent_image_ids(image_ids)
  existent_images = list_images(image_ids)
  image_ids - existent_images.map(&:image_id)
rescue Aws::EC2::Errors::InvalidAMIIDNotFound => e
  e.message.match(/\[.*\]/)[0].gsub(/\[|\]|\s/, '').split(',')
end

def list_images(image_ids)
  client.describe_images(image_ids: image_ids).images
end

def client
  @client ||= Aws::EC2::Client.new
end

main
