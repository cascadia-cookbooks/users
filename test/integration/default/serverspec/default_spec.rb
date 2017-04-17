require 'spec_helper'

describe 'users::default' do
    describe user('test') do
        it { should exist }
        it { should belong_to_group 'test' }
        it { should have_home_directory "/home/test" }
    end

    describe file('/home/test/.ssh') do
        it { should be_directory }
        it { should exist }
        it { should be_mode 700 }
        it { should be_owned_by 'test' }
        it { should be_grouped_into 'test' }
    end

    describe file('/home/test/.ssh/authorized_keys') do
        it { should be_file }
        it { should exist }
        it { should contain 'ssh-rsa TEST-KEY' }
        it { should be_mode 600 }
        it { should be_owned_by 'test' }
        it { should be_grouped_into 'test' }
    end

    describe user('fail') do
        it { should_not exist }
    end

    describe file('/home/fail/.ssh') do
        it { should_not exist }
    end
end
