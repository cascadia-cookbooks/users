# Users Cookbook

### Manages system users

The purpose of this cookbook is to create and manage system users.

### Default Attributes

`node['users']['group']['admin']`: The name of the administrator group, defaults to `adm`.

`node['users']['passwordless_sudo']`: Whether passwordless-sudo is enabled, defaults to `false`.

### Usage

Create data-bags for each user to be managed. The following data structure is assumed:

```
.
└── data_bags
    └── users
        ├── user1.json
        └── user2.json
```

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
