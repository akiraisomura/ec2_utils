# frozen_string_literal: true

require 'aws-sdk'
require 'dotenv/load'
require 'slack-notifier'
require 'active_support/all'
require_relative './list_snapshots_without_volume.rb'

def main
  snapshots_without_volume = list_snapshots_without_volume

  message = make_alert_message(snapshots_without_volume)
  post_message(message)
end


def make_alert_message(snapshots_without_volume)
  target = snapshots_without_volume.map { |s| "`id: #{s.snapshot_id}, v-size: #{s.volume_size}, start_time: #{s.start_time}``" }.join("\n")
  message = "There are snapshots without volume \n %{target}"
  format(message, target: target)
end

def post_message(message)
  attachment = {
    text: message,
    color: 'warning'
  }

  slack.post(attachments: [attachment])
end

def slack
  @slack ||= Slack::Notifier.new(
    ENV['SLACK_URL'],
    channel: ENV['SLACK_CHANNEL'],
    username: 'Unused EBS Volume alert'
  )
end

def client
  @client ||= Aws::EC2::Client.new
end

main
