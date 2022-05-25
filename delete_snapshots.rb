# frozen_string_literal: true

require 'aws-sdk'
require_relative './list_snapshots_without_volume.rb'

def main
  snapshots = list_snapshots_without_volume
  snapshots.each { |s| client.delete_snapshot(snapshot_id: s.snapshot_id) }
end

def client
  @client ||= Aws::EC2::Client.new
end

main
