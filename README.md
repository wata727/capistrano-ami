# Capistrano AMI

[![build status](https://circleci.com/gh/wata727/capistrano-ami.svg?style=shield&circle-token=490e040fc0a638ff54e85f9f0ac71c0330bcafa6)](https://circleci.com/gh/wata727/capistrano-ami)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/capistrano-ami.svg)](https://rubygems.org/gems/capistrano-ami)

This plugin that create AMI (Amazon Machine Image) and manage generations tasks into capistrano script. `capistrano-ami` tasks are able to run when deploy target servers exists in AWS (http://aws.amazon.com/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-ami'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-ami

## Usage
Load `capistrano-ami` into your capistrano configuration file `Capfile`:
```ruby
require 'capistrano/ami'
```
And set config values in deploy script `config/deploy.rb`:
```ruby
set :aws_region, 'ap-northeast-1'  # deploy servers region name
set :base_ami_name, 'web-role'     # name: "#{base_ami_name}_#{instance_id}_#{deploy_timestamp}" default is capistrano-ami
set :keep_amis, 3                  # keeps number of AMIs. default is 5
```
If you do not specify, `base_ami_name` and `keep_amis` uses default value.

### Credentials

`capistrano-ami` supports various credential providers. As of the following priority:

- Specified shared credentials
- Key values
- Environment values
- Default shared credentials
- IAM role

#### Key values

You can set credentials in deploy script `config/deploy.rb`:
```ruby
set :aws_access_key_id, 'YOUR_AWS_ACCESS_KEY'
set :aws_secret_access_key, 'YOUR_AWS_SECRET_KEY'
```

#### Environment values

`capistrano-ami` looks `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` environemt values.
```
$ export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY
$ export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY
```

If you do not want to fix region in deploy script. use `AWS_REGION` environment values and other credential providers.

#### Shared credentials

Shared credentials are credentials file in local machine. default location is `~/.aws/credentials`. [More infomation](https://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs).
If you want to use `default`, do not specify key values in delopy script. But if you want to use other profile, you should specify following:

```ruby
set :aws_credentials_profile_name, 'profile_name'
```

#### IAM role

IAM role is most secure credential provider. If you can, should use this. [More infomation](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html).
This provider used in no credentials configuration. Because you should not specify key values.

## Versions

We check working this plugin following platform versions.

- Ruby 
    - 2.3.0
- Capistrano 
    - 3.5.0

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wata727/capistrano-ami. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
