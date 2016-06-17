# Mettric

Tracks events, meter readings and timings to [riemann.io](http://riemann.io) in a background thread using [riemann-ruby-client](https://github.com/riemann/riemann-ruby-client). Fire and forget. 

## Configuration

```ruby
Mettric.config = {
  host: 'my-riemann-server',
  port: 5555,

  reporting_host: 'override' # Defaults to system hostname
  app: 'my_app'              # Defaults to rails app (if in rails)
  poll_intervall: 100        # Defaults to 50ms
}
```

## Track events

```ruby
# Tracks payload with metric=1 and tags it 'event'
🛎 service: 'User created'
```

## Track meter readings

```ruby
🌡 service: 'Rails req/s', metric: 400, state: 'normal'
```

## Time things

```ruby
# This will track the duration in milliseconds as the `metric` value
# as "Sleep duration ms" (note the added ' ms') and tag it 'timing'
⏱ (service: 'Sleep duration') do
  sleep 1
end
```

## For grown ups

Just in case you don't want to use the silly methods names, please know that the emoji variants of above methods just call `Mettric.event(payload)`, `Mettric.meter(payload` and `Mettric.time(paylod) { ... }` respectively. Be aware, though, that the emoji methods ignore a misconfigured or unavailable riemann server by rescuing `Mettric::CouldNotStartWorkerThread` exceptions. The non-emoji methods will throw that exception. Just have a look at [lib/mettric/scnr.rb](lib/mettric/scnr.rb) and you'll see what I mean.
