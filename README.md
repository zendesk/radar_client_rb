### Radar Ruby Client

This gem lets you read radar resources directly from redis. You can also set radar Status resource.

```ruby

require 'radar_client_rb'


client = Radar::Client.new(redis_connection, account_name, user_id)

# read resources
msg = client.message('chat/123/messages').get
presence_list = client.presence('ticket/1')/.get
status = client.status('ticket/1').get

# set status
client.status('ticket/1').set(user_id4, { :state => 'updated' })

```
