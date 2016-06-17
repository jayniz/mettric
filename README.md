# Mettric

Tracks events, meter readings and timings to [riemann.io](http://riemann.io) in a background thread using [riemann-ruby-client](https://github.com/riemann/riemann-ruby-client). Fire and forget.

Mettric will also prepend your app's name to the services you track with riemann and set the reporting host and tags automatically.


## Getting started

```ruby
gem install mettric
```


### Configuration

You can configure Mettric like this:

```ruby
Mettric.config = {
  host: 'my-riemann-server',
  port: 5555,

  reporting_host: 'override', # Defaults to system hostname
  app: 'my_app',              # Defaults to rails app (if in rails)
  poll_intervall: 100,        # Defaults to 50 (ms)
  sidekiq_middleware: false   # Defaults to true
}
```

Upon configuration, Mettric will install a [sidekiq](http://sidekiq.org/) middleware that automatically tracks the success and error rates of your workers as well as their duration (see below for details)


### Track events

```ruby
# Tracks payload with metric=1 and tags it 'event'
🛎 service: 'users.created'

# Will send the following payload via riemann-ruby-client:
#
# {
#    host: 'override',
#    service: 'my_app.users.created',
#    metric: 1,
#    tags: ['event']
# }
```

### Track meter readings

```ruby
🌡 service: 'Rails req/s', metric: 400, state: 'normal'

# Will send the following payload via riemann-ruby-client:
#
# {
#    host: 'override',
#    service: 'my_app.Rails req/s',
#    metric: 400,
#    state: 'normal'
# }
```

### Time things

```ruby
⏱ (service: 'test.slept', tags: [:tired]) do
  sleep 1
end

# Will send the following payload via riemann-ruby-client:
#
# {
#    host: 'override',
#    service: 'my_app.test.slept',
#    metric: 1000,
#    description: '(ms)',
#    tags: ['timing', 'tired']
# }
```

### For grown ups

Just in case you don't want to use the silly methods names, please know that the emoji variants of above methods just call `Mettric.event(payload)`, `Mettric.meter(payload` and `Mettric.time(paylod) { ... }` respectively. Be aware, though, that the emoji methods ignore a misconfigured or unavailable riemann server by rescuing `Mettric::CouldNotStartWorkerThread` exceptions. The non-emoji methods will throw that exception. Just have a look at [lib/mettric/scnr.rb](lib/mettric/scnr.rb) and you'll see what I mean.


## Sidekiq

Let's assume you have sidekiq worker class called `MyWorker` that uses the `my_queue` queue. Each time it runs, Mettric will automatically track how long the worker took by sending the following payload to Riemann (assuming the worker took 80ms):

```ruby
{
  host: 'override',
  service: 'my_app.sidekiq.queue:my_queue.worker:my_worker.duration',
  metric: 80,
  tags: ['sidekiq']
}
```

Also, it will track the success

```ruby
{
  host: 'override',
  service: 'my_app.sidekiq.queue:my_queue.worker:my_worker.success',
  metric: 1,
  tags: ['event']
}
```

or error

```ruby
{
  host: 'override',
  service: 'my_app.sidekiq.queue:my_queue.worker:my_worker.error',
  metric: 1,
  tags: ['event']
}
```

of the worker's execution. If you want a worker not to be tracked by mettric, you would write:

```ruby
class MyWorker
  include Sidekiq::Worker
  sidekiq_options mettric: false

  def perform
    …
  end
end
