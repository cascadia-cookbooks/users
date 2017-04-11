#
# Cookbook Name:: users
# Recipe:: default
#

users = data_bag('users')

admin_users = []
admin_group = node['users']['group']['admin']

users.each do |u|
    user = data_bag_item('users', u)
    home = "/home/#{user['id']}"
    admin_users << user['id'] if user['groups'] && user['groups'].include?('sudo')

    user_exists = (`id #{user['id']} || echo 'false'`.strip != 'false')

    if user['action'].to_s != 'create' && !user_exists
        admin_user.delete(user['id'])
        Chef::Log.warn("Skipping action: '#{user['action']}' of no-existing user '#{user['id']}'")
    else
        user user['id'] do
            home        home
            shell       (user['shell'].nil? || user['shell'].empty? ? "/bin/bash" : user['shell'])
            action      user['action']
            comment     user['comment']
            manage_home true
        end
    end

    case user['action']
        when 'create'
            directory "#{home}/.ssh" do
                owner user['id']
                mode  0700
            end

            directory "#{home}/.config" do
                owner user['id']
                group user['id']
                mode  0700
            end

            execute "set #{user['id']} as owner of homedir configs" do
                command "find #{home}/.config/ | xargs chown #{user['id']}; \
                         find #{home}/.config/ -type f | xargs chmod 0600; \
                         find #{home}/.config/ -type d | xargs chmod 0700"
                action  :run
                ignore_failure true
            end

            file "#{home}/.ssh/authorized_keys" do
                owner   user['id']
                mode    0600
                content "# Chef generated file. Edits will be lost.\n#{user['ssh_keys'].join("\n")}"
                backup  false
            end

        when 'remove'
            users.delete(user['id'])
    end
end

# Add 'vagrant' user to admin group when in development environment
if node.chef_environment == "development"
    admin_users << 'vagrant'
end

# NOTE: Members are reassigned each Chef run, not appeneded
# Add users to admin group
group "Admin for users: #{admin_users.join(', ')}" do
    group_name admin_group
    action     :modify
    members    admin_users
end

# Enable passwordless sudo if set, include check so we dont multi-append on each Chef run
if node['users']['passwordless_sudo']
    execute "enable passwordless sudo for group #{admin_group}" do
        command "echo '#check\n%#{admin_group}\tALL=(ALL)\tNOPASSWD: ALL' >> /etc/sudoers"
        not_if  "grep '#check' /etc/sudoers"
    end
end