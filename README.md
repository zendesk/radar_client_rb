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

### Releasing a new version
A new version is published to RubyGems.org every time a change to `version.rb` is pushed to the `main` branch.
In short, follow these steps:
1. Update `version.rb`,
2. update version in all `Gemfile.lock` files,
3. merge this change into `main`, and
4. look at [the action](https://github.com/zendesk/radar_client_rb/actions/workflows/publish.yml) for output.

To create a pre-release from a non-main branch:
1. change the version in `version.rb` to something like `1.2.0.pre.1` or `2.0.0.beta.2`,
2. push this change to your branch,
3. go to [Actions → “Publish to RubyGems.org” on GitHub](https://github.com/zendesk/radar_client_rb/actions/workflows/publish.yml),
4. click the “Run workflow” button,
5. pick your branch from a dropdown.

## Copyright and license
Copyright 2016 Zendesk
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
