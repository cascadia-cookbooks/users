# Users Cookbook

### Manages system users

The purpose of this cookbook is to create and manage system users.

### Default Attributes

`node['users']['group']['admin']`: The name of the administrator group, defaults to `adm`.

### Usage

Create data-bags for each user to be managed. The following data structure is assumed:

```
.
└── data_bags
    └── users
        ├── amy.json
        ├── bob.json
        ├── carl.json
        ├── dumplefweez.json
        └── ed.json
```

### User List

The `node['users']['user_list']` attribute controls which data-bags will be included in the `cop_users` run. This attribute can be set on a per-environment basis to include or exclude users from different environments. For example:
```
$ cat chef/environments/staging.rb
default_attributes(
    ...
    users: {
        user_list: %w(
            amy
            bob
            carl
            ed
        )
    },
    ...
```
The `user_list` is based on the name of the data-bag, it has no knowledge of the contents. Make sure that your `user_list` references data-bag names and not expected user ID's.

### Data Bag Format

This recipe expects a data bag in the following format:

```
{
    "id": "test",
    "action": "create",
    "comment": "Test User",
    "groups": ["sudo"],
    "ssh_keys": ["ssh-rsa TEST-KEY"]
}
```

### Recommendations

It is recommended to avoid setting `"action": "remove"` in a users data-bag as this can lead to both unwanted data termination as well as a potential conflict with attempting to remove a user that no longer exists. The preferred method to disable a user is to set `"action": "lock"` in that users data-bag.
