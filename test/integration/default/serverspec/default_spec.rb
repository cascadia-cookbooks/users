require 'spec_helper'

describe 'users::default' do
    describe user('alice') do
        it { should exist }
        it { should belong_to_group 'alice' }
        it { should belong_to_group 'sudo' }
        it { should belong_to_group 'umbrella' }
        it { should have_home_directory '/home/alice' }
    end

    describe file('/home/alice/.ssh') do
        it { should be_directory }
        it { should exist }
        it { should be_mode 700 }
        it { should be_owned_by 'alice' }
        it { should be_grouped_into 'alice' }
    end

    describe file('/home/alice/.ssh/authorized_keys') do
        it { should be_file }
        it { should exist }
        it { should contain 'ssh-rsa alice-key' }
        it { should be_mode 600 }
        it { should be_owned_by 'alice' }
        it { should be_grouped_into 'alice' }
    end

    describe user('carol') do
        it { should_not exist }
    end

    describe file('/home/carol/.ssh') do
        it { should_not exist }
    end

    describe file('/home/gertrude/.ssh/authorized_keys') do
        it { should_not exist }
    end
end
