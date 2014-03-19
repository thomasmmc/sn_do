# sn_do
This is to talk to ServiceNow instances to work thru the data, generate statistics and other useful information

This is currently under aplha testing and will be updated rapidly

## Whats here:

* `sn_do.rb` - This is our SN_DO module and Classes for interacting with Incidents and Assets
* `example.rb` - How to use SN_DO in a useful way calling most methods to meet some goals

## gems used
``` ruby
require 'net/https'
require 'rexml/document'
require 'net/smtp'
```

### Example for using SN_DO and connecting to ServiceNow and getting a count
`example.rb` is goign to have more detailed example then this
``` ruby
SN_DO::INC.new('demo017','admin','admin')
httpresult = SN_DO::INC.retrieve('XML','assignment_group', assign_group_id)
incident_list = SN_DO::INC.parse_xml(httpresult)
total_incidents = incident_list.count
puts total_incidents
```

## todo list
* build tests
* document things better
* build out the asset class