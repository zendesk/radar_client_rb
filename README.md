### Radar Ruby Client

This gem lets you read radar resources directly from Redis. You can also set radar Status resource.

[![Gem Version](https://badge.fury.io/rb/radar_client_rb.svg)](https://badge.fury.io/rb/radar_client_rb)
![CI](https://github.com/zendesk/radar_client_rb/workflows/CI/badge.svg)

```ruby

require 'radar_client_rb'


client = Radar::Client.new(account_name, redis_connection)

# read resources
msg = client.message('chat/123/messages').get
presence_list = client.presence('ticket/1')/.get
status = client.status('ticket/1').get

# set status
client.status('ticket/1').set(user_id4, { :state => 'updated' })

```

## Copyright and license
Copyright 2016 Zendesk
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

