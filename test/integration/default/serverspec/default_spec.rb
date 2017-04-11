require 'spec_helper'

describe 'users::default' do
    describe user('test') do
        it { should exist }
        it { should belong_to_group 'test' }
        it { should have_home_directory "/home/test" }
    end
end
