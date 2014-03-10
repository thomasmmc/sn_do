# sn_do
This is to talk to ServiceNow instances and generate statistics and other useful information

This is currently under aplha testing and will be updated rapidly

## gems
...require 'yaml'
...require 'net/https'
...require 'rexml/document'
...require 'net/smtp'

## config file
Below you will see the vairables we are setting for your ServiceNow instance

### ServiceNow instance and assignment group settings
``` ruby
instance_name: demo017
username: admin
password: admin
assign_group_id: d625dccec0a8016700a222a0f7900d06
assign_group_name: Software
```

## todo list
* refactor, refactor, refactor
* remove built in email function (part of alpha testing)