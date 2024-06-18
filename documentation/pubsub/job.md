# Player messages
Messages related to the player and their server

### Job changed - `:job_updated`
Sent when a job is changed.

```elixir
%{
  event: :job_updated,
  job_id: Job.id(),
  job: job
}
```

