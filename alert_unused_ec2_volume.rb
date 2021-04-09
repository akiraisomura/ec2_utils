# frozen_string_literal: true

require 'aws-sdk'
require 'dotenv/load'
require 'slack-notifier'
require 'active_support/all'

def main
  resp = client.describe_volumes

  alert_volume_id_to_names = resp.volumes.map do |volume|
    next if volume.attachments.present?

    name = fetch_name(volume.tags)
    { volume_id: volume.volume_id, name: name }
  end.compact

  message = make_alert_message(alert_volume_id_to_names)
  post_message(message)
end

def fetch_name(tags)
  tags.find { |t| t.key == "Name" }.value
end

def make_alert_message(alert_volume_id_to_names)
  target = alert_volume_id_to_names.map { |a| "`volume id: #{a[:volume_id]}, name: #{a[:name]}`" }.join("\n")
  message = "There are unused ebs volumes \n %{target}"
  format(message, target: target)
end


def post_message(message)
  attachment = {
    text: message,
    color: 'warning'
  }

  Slack::Notifier.new(
    ENV['SLACK_URL'],
    channel: ENV['SLACK_CHANNEL'],
    username: 'Unused EBS Volume alert'
  ).post(attachments: [attachment])
end


def client
  @client ||= Aws::EC2::Client.new
end

main
