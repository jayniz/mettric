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

## Track metrics

```ruby
🌡 service: 'Rails req/s', metric: 400, state: 'normal'
```
