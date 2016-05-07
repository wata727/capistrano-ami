require 'spec_helper'

describe Capistrano::Ami do
  before do
    # set region in all test
    set :aws_region, 'ap-northeast-1'
  end

  it 'has a version number' do
    expect(Capistrano::Ami::VERSION).not_to be nil
  end

  describe 'credentials' do
    before do
      # init capistrano configuration
      delete :aws_access_key_id
      delete :aws_secret_access_key
      # use capistrano-ami module method
      extend Capistrano::Ami::Instance
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
      stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({body: /Action=DescribeInstances/}).to_return status: 200, body: aws_api_response_mock('DescribeInstances.xml')
      stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({body: /Action=CreateImage/}).to_return status: 200, body: aws_api_response_mock('CreateImage.xml')
      stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({body: /Action=CreateTags/}).to_return status: 200, body: aws_api_response_mock('CreateTags.xml')
      stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({body: /Action=DescribeImages/}).to_return status: 200, body: aws_api_response_mock('DescribeImages.xml')

      ami = Capistrano::Ami.create('i-1234abcd', 'capistrano-ami')
      expect(ami.id).to eq 'ami-1234abcd'
      expect(ami.tags.map { |tag| [tag.key, tag.value] }).to match_array([['created_by', 'capistrano-ami'], ['base_instance_id', 'i-1234abcd']])
    end
  end

  describe 'fetch old AMIs' do
    it 'when has more than keep_amis' do
      # webmock
      stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({body: /Action=DescribeImages/}).to_return status: 200, body: aws_api_response_mock('DescribeImages.xml')

      amis = Capistrano::Ami.old_amis('i-1234abcd', 1)
      expect(amis.size).to eq 1
      expect(amis.map { |ami| ami.id }).to match_array(['ami-1234abcd'])
    end

    it 'when has less than keep_amis' do
      # webmock
      stub_request(:post, 'https://ec2.ap-northeast-1.amazonaws.com/').with({body: /Action=DescribeImages/}).to_return status: 200, body: aws_api_response_mock('DescribeImages.xml')

      amis = Capistrano::Ami.old_amis('i-1234abcd', 3)
      expect(amis.size).to eq 0
    end
  end

  describe 'delete snapshot' do
    it 'normally' do
    end
  end
end
