#
# Cookbook Name:: users
# Recipe:: default
#

user_list = node['users']['user_list']
users     = data_bag('users')

group_list = node['users']['group_list']

# Check that each user in user_list has a corresponding data bag
user_list.each do |ul|
    unless users.include?(ul)
        Chef::Log.warn("User #{ul} has no corresponding data bag, skipping")
    end
end

users.each do |u|
    user = data_bag_item('users', u)
    if user_list.include?(u)
        home = "/home/#{user['id']}"

        user_exists = (`id #{user['id']} || echo 'false'`.strip != 'false')

        if user['action'].to_s != 'create' && !user_exists
            Chef::Log.warn("Skipping action: '#{user['action']}' of non-existing user '#{user['id']}'")
        else
            user user['id'] do
                home        home
                shell       (user['shell'].nil? || user['shell'].empty? ? "/bin/bash" : user['shell'])
                action      user['action']
                comment     user['comment']
                manage_home true
                notifies    :reload, 'ohai[reload_passwd]', :immediately
            end

            # Include user in their own group
            group user['id'] do
                group_name user['id']
                action     :create
                members    user['id']
                notifies   :reload, 'ohai[reload_passwd]', :immediately
            end
        end

        case user['action']
            when 'create'
                directory "#{home}/.ssh" do
                    owner user['id']
                    group user['id']
                    mode  0700
                end

                directory "#{home}/.config" do
                    owner user['id']
                    group user['id']
                    mode  0700
                end

                if user['ssh_keys']
                    file "#{home}/.ssh/authorized_keys" do
                        owner   user['id']
                        group   user['id']
                        mode    0600
                        content "# Chef generated file. Edits will be lost.\n#{user['ssh_keys'].join("\n")}"
                        backup  false
                    end
                end

            when 'remove'
                users.delete(user['id'])
        end
    end
end

# NOTE: Members are reassigned each Chef run, not appeneded
group_list.each do |g|
    # Wipe member_list for each group
    member_list = []

    users.each do |u|
        user = data_bag_item('users', u)
        # Check that user_list allows user
        if user_list.include?(u)
            if user['groups'] && user['groups'].include?(g)
                member_list << user['id']
            end
        end
    end

    # Assign member_list to group
    group g do
        group_name g
        action     :create
        members    member_list
        notifies   :reload, 'ohai[reload_passwd]', :immediately
    end
end

# Reload ohai 'etc' plugin
ohai 'reload_passwd' do
    action :nothing
    plugin 'etc'
end
