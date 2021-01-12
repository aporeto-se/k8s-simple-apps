# three-tier-single-ns
This is a simple three tier application consisting of a frontned, middleware and backend pod set.

### frontend
This podset represnets a frontend web server serving inbound connections. The provided script frontned.sh will start the webserver and then start an event loop that will attempt to connect to the middleware podset.
