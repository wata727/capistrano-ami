require 'spec_helper'

describe Capistrano::Ami do
  before do
    # set region in all test
    set :aws_region, 'ap-northeast-1'
    # use capistrano-ami module method
    extend Capistrano::Ami::Instance
  end

  it 'has a version number' do
    expect(Capistrano::Ami::VERSION).not_to be nil
  end

  describe 'credentials' do
    before do
      # init capistrano configuration
      delete :aws_access_key_id
      delete :aws_secret_access_key
    end

    it 'by config values' do
      set :aws_access_key_id, 'ABCDEFGHIJ0123456789'
      set :aws_secret_access_key, 'abcdefghij0123456789ABCDEFGHIJ0123456789'
      expect(credentials(nil).set?).to be true
    end

    it 'by environment values' do
      allow(ENV).to receive(:[]).with('AWS_ACCESS_KEY_ID').and_return('ABCDEFGHIJ0123456789')
      allow(ENV).to receive(:[]).with('AWS_SECRET_ACCESS_KEY').and_return('abcdefghij0123456789ABCDEFGHIJ0123456789')
      expect(credentials(nil).set?).to be true
    end

    it 'by shared credentials' do
      sharedcredentials = <<EOS
[test_credentials]
aws_access_key_id = ABCDEFGHIJ0123456789
aws_secret_access_key = abcdefghij0123456789ABCDEFGHIJ0123456789
EOS
      allow(File).to receive(:read).with(File.join(Dir.home, '.aws', 'credentials')).and_return(sharedcredentials)
      expect(credentials('test_credentials').set?).to be true
    end

    it 'by IAM role' do
      # TODO: require test that client is authorized
      expect(credentials(nil).set?).to be false
    end
  end

  describe 'create AMI' do
    it 'normally' do
      # webmock
      api_mock('DescribeInstances')
      api_mock('CreateImage')
      api_mock('CreateTags')
      api_mock('DescribeImages')

      ami = Capistrano::Ami.create('i-1234abcd', 'capistrano-ami')
      expect(ami.id).to eq 'ami-1234abcd'
      expect(ami.tags.map { |tag| [tag.key, tag.value] }).to match_array([['created_by', 'capistrano-ami'], ['base_instance_id', 'i-1234abcd']])
    end
  end

  describe 'fetch old AMIs' do
    it 'when has more than keep_amis' do
      # webmock
      api_mock('DescribeImages')

      amis = Capistrano::Ami.old_amis('i-1234abcd', 1)
      expect(amis.size).to eq 1
      expect(amis.map(&:id)).to match_array(['ami-1234abcd'])
    end

    it 'when has less than keep_amis' do
      # webmock
      api_mock('DescribeImages')

      amis = Capistrano::Ami.old_amis('i-1234abcd', 3)
      expect(amis.size).to eq 0
    end
  end

  describe 'delete snapshot' do
    it 'when has a snapshot' do
      # get ami object
      api_mock('DescribeImages')
      amis = Capistrano::Ami.old_amis('i-1234abcd', 1)
      # webmock
      api_mock('DeleteSnapshot')

      expect_any_instance_of(Aws::EC2::Client).to receive(:delete_snapshot).with({ snapshot_id: 'snap-1234abcd' })
      Capistrano::Ami.delete_snapshot(amis.first.block_device_mappings)
    end

    it 'when has many snapshots' do
      # get ami object
      api_mock('DescribeImages')
      amis = Capistrano::Ami.old_amis('i-1234abcd', 0)
      # webmock
      api_mock('DeleteSnapshot')

      expect_any_instance_of(Aws::EC2::Client).to receive(:delete_snapshot).with({ snapshot_id: 'snap-1234abcd' })
      expect_any_instance_of(Aws::EC2::Client).to receive(:delete_snapshot).with({ snapshot_id: 'snap-1a2b3c4d' })
      expect_any_instance_of(Aws::EC2::Client).to receive(:delete_snapshot).with({ snapshot_id: 'snap-a1b2c3d4' })
      amis.each do |ami|
        Capistrano::Ami.delete_snapshot(ami.block_device_mappings)
      end
    end
  end
end
