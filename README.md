# Mettric

Track to riemann.

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
