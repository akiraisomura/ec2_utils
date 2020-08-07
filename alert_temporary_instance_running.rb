# frozen_string_literal: true

require 'aws-sdk'
require 'time'
require 'dotenv/load'
require 'slack-notifier'
require 'yaml'

def main
  alert_target_instances = select_alert_target_instances(
    config['tags'], config['states'], config['launch_from_hour']
  )
  return if alert_target_instances.empty?

  message = make_alert_message(alert_target_instances)
  post_message(message)
end

def make_alert_message(alert_target_instances)
  alert_instances_info = alert_target_instances.map do |i|
    name = i.tags.find { |t| t['key'] == 'Name' }['value']
    "`Name: #{name}, launch_time: #{i.launch_time}`"
  end

  format(config['message'], instances: alert_instances_info.join("\n"))
end

def select_alert_target_instances(tags, states, launch_from_hour)
  ec2.instances(filters: tags)
    .select { |i| states.include?(i&.state&.name) && ((Time.now - i.launch_time).to_i / 60 / 60) >= launch_from_hour }
end

def post_message(message)
  attachment = {
    text: message,
    color: 'warning'
  }

  Slack::Notifier.new(
    ENV['SLACK_URL'],
    channel: ENV['SLACK_CHANNEL'],
    username: 'Temporal EC2 instances alert'
  ).post(attachments: [attachment])
end

def config
  @config ||= YAML.load_file('config/setting.yml')
end

def ec2
  @ec2 ||= Aws::EC2::Resource.new
end

main
