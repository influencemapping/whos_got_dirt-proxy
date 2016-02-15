# Who's got dirt? CSV Proxy

[![Dependency Status](https://gemnasium.com/influencemapping/whos_got_dirt-proxy.png)](https://gemnasium.com/influencemapping/whos_got_dirt-proxy)
[![Code Climate](https://codeclimate.com/github/influencemapping/whos_got_dirt-proxy.png)](https://codeclimate.com/github/influencemapping/whos_got_dirt-proxy)

This server forwards requests to the [Who's got dirt? federated search API for influence data](https://github.com/influencemapping/whos_got_dirt-server/) and returns responses as CSV.

## Development

```
bundle
WHOS_GOT_DIRT_API_URL=https://whosgotdirt.herokuapp.com bundle exec rackup
```

## Deployment

```
heroku apps:create
heroku config:set WHOS_GOT_DIRT_API_URL=https://whosgotdirt.herokuapp.com
git push heroku master
```

Copyright (c) 2016 James McKinney, released under the MIT license
