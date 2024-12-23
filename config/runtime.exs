import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/myapp start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :myapp, MyAppWeb.Endpoint, server: true
end

if config_env() == :prod do
  System.get_env("DATABASE_USERNAME") || raise "environment variable DATABASE_USERNAME is missing"

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :myapp, MyApp.Repo,
    # ssl: true,
    username: System.get_env("DATABASE_USERNAME"),
    password: System.get_env("DATABASE_PASSWORD"),
    hostname: System.get_env("DATABASE_HOSTNAME"),
    database: System.get_env("DATABASE_DB_NAME"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || System.get_env("DOMAIN_NAME")
  domain_name = System.get_env("DOMAIN_NAME") || raise "DOMAIN_NAME not set"

  config :myapp, MyAppWeb.Endpoint,
    url: [
      host: host,
      scheme: "https"
    ],
    https: [
      port: String.to_integer(System.get_env("HTTPS_PORT") || "8888"),
      keyfile: "/etc/letsencrypt/live/#{domain_name}/privkey.pem",
      certfile: "/etc/letsencrypt/live/#{domain_name}/cert.pem",
      cacertfile: "/etc/letsencrypt/live/#{domain_name}/fullchain.pem",
      versions: [:"tlsv1.2"],
      dhfile: ~c"/var/www/tls/dh-params.pem",
      ciphers: [
        ~c"ECDHE-ECDSA-AES256-GCM-SHA384",
        ~c"ECDHE-RSA-AES256-GCM-SHA384",
        ~c"ECDHE-ECDSA-AES256-SHA384",
        ~c"ECDHE-RSA-AES256-SHA384",
        ~c"ECDHE-ECDSA-DES-CBC3-SHA",
        ~c"ECDH-ECDSA-AES256-GCM-SHA384",
        ~c"ECDH-RSA-AES256-GCM-SHA384",
        ~c"ECDH-ECDSA-AES256-SHA384",
        ~c"ECDH-RSA-AES256-SHA384",
        ~c"DHE-DSS-AES256-GCM-SHA384",
        ~c"DHE-DSS-AES256-SHA256",
        ~c"AES256-GCM-SHA384",
        ~c"AES256-SHA256",
        ~c"ECDHE-ECDSA-AES128-GCM-SHA256",
        ~c"ECDHE-RSA-AES128-GCM-SHA256",
        ~c"ECDHE-ECDSA-AES128-SHA256",
        ~c"ECDHE-RSA-AES128-SHA256",
        ~c"ECDH-ECDSA-AES128-GCM-SHA256",
        ~c"ECDH-RSA-AES128-GCM-SHA256",
        ~c"ECDH-ECDSA-AES128-SHA256",
        ~c"ECDH-RSA-AES128-SHA256",
        ~c"DHE-DSS-AES128-GCM-SHA256",
        ~c"DHE-DSS-AES128-SHA256",
        ~c"AES128-GCM-SHA256",
        ~c"AES128-SHA256",
        ~c"ECDHE-ECDSA-AES256-SHA",
        ~c"ECDHE-RSA-AES256-SHA",
        ~c"DHE-DSS-AES256-SHA",
        ~c"ECDH-ECDSA-AES256-SHA",
        ~c"ECDH-RSA-AES256-SHA",
        ~c"AES256-SHA",
        ~c"ECDHE-ECDSA-AES128-SHA",
        ~c"ECDHE-RSA-AES128-SHA",
        ~c"DHE-DSS-AES128-SHA",
        ~c"ECDH-ECDSA-AES128-SHA",
        ~c"ECDH-RSA-AES128-SHA",
        ~c"AES128-SHA"
      ],
      secure_renegotiate: true,
      reuse_sessions: true,
      honor_cipher_order: true
    ],
    force_ssl: [hsts: true],
    root: ".",
    cache_static_manifest: "priv/static/cache_manifest.json",
    server: true,
    check_origin: ["//#{domain_name}", "//*.#{domain_name}"],
    version: "0.0.1",
    secret_key_base: secret_key_base

  config :fontawesome,
    free_only: System.get_env("FONTAWESOME_FREE_ONLY", "TRUE") == "TRUE"
end
