require 'spec_helper'

describe Capistrano::Ami do
  it 'has a version number' do
    expect(Capistrano::Ami::VERSION).not_to be nil
  end

  describe 'credentials' do
    before do
      # init capistrano configuration
      delete :aws_region
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
      set :aws_region, 'ap-northeast-1'
      # TODO: require test that client is authorized
      expect(credentials(nil).set?).to be false
    end
  end

  describe 'CreateAMI' do
    it 'create new AMI' do
    end
  end

  describe 'FetchOldAMIs' do
    it 'fetch old AMIs when has more than keep_amis' do
    end

    it 'fetch old AMIs when has less than keep_amis' do
    end

    it 'fetch old AMIs when has other tag AMIs' do
    end
  end

  describe 'DeleteSnapshot' do
    it 'delete snapshot' do
    end
  end
end
