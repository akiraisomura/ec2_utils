# EC2 util

ec2 util is a ruby script list for dealing with ec2 issue.


## Usage

### alert_temporary_instance_running
```
1. Bundle install

2. make .env file with below elements
  - SLACK_URL: your slack webhook url
  - SLACK_CHANNEL: target slack channnel

3. edit config/setting.yml
  - tags: select instances with this values
  - launch_from_hour: alert if instances were launched before this hour
  - states: select instances with this states
  - message: you can customize alert message

4. bundle exec ruby alert_temporary_instance_running.rb
```

### alert_unused_ec2_volume
```
1. Bundle install

2. make .env file with below elements
  - SLACK_URL: your slack webhook url
  - SLACK_CHANNEL: target slack channnel

3. bundle exec ruby alert_unused_ec2_volume.rb
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
