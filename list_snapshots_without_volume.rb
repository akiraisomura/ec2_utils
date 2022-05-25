# frozen_string_literal: true

require 'aws-sdk'
require 'active_support/all'

def main
  snapshots_without_volume = list_snapshots_without_volume
  p snapshots_without_volume.map { |s| "id: #{s.snapshot_id}, v-size: #{s.volume_size}, start_time: #{s.start_time}" }
end

def list_snapshots_without_volume
  snapshots = client.describe_snapshots(owner_ids: ["self"]).snapshots
  all_volume_ids = client.describe_volumes.volumes.map(&:volume_id)
  snapshots.reject { |s| s.volume_id.in?(all_volume_ids) }
end

def client
  @client ||= Aws::EC2::Client.new
end

main
