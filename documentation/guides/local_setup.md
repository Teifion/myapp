# Local setup
This is a guide for developing MyApp locally. If you are just deploying MyApp then you likely will not need this guide. MyApp is a [Phoenix](https://www.phoenixframework.org/) project with a few extra steps. This guide is primarily aimed at those who are new to Elixir/Phoenix.

## Install services
You will need to install:
- [Elixir/Erlang installed](https://elixir-lang.org/install.html).
- [Postresql](https://www.postgresql.org/download).

I prefer using [asdf](https://github.com/asdf-vm/asdf) and have included a `.tool-versions` to enable you to simply `asdf install`.

## Clone repo and pull dependencies
```bash
git clone git@github.com:Teifion/MyApp.git
cd myapp
mix deps.get && mix deps.compile
```

## Postgres setup
If you want to change the username or password then you will need to update the relevant files in [config](/config).
```bash
sudo su postgres
psql postgres postgres <<EOF
CREATE USER myapp_dev WITH PASSWORD 'postgres';
CREATE DATABASE myapp_dev;
GRANT ALL PRIVILEGES ON DATABASE myapp_dev to myapp_dev;
ALTER USER myapp_dev WITH SUPERUSER;

CREATE USER myapp_test WITH PASSWORD 'postgres';
CREATE DATABASE myapp_test;
GRANT ALL PRIVILEGES ON DATABASE myapp_test to myapp_test;
ALTER USER myapp_test WITH SUPERUSER;
EOF
exit
```

## SASS
We use sass for our css generation and you'll need to run this to get it started.
```bash
mix sass.install
```

## Running it
Standard mode
```bash
mix phx.server
```

Interactive REPL mode
```bash
iex -S mix phx.server
```

If all goes to plan you should be able to access your site locally at [http://localhost:4000/](http://localhost:4000/).

### Libraries you need to get yourself
The site makes liberal use of [FontAwesome](https://fontawesome.com/) so if you are using the site you'll need to download it and do the following
```bash
fontawesome/css/all.css -> priv/static/css/fontawesome.css
fontawesome/webfonts -> priv/static/webfonts
```

## Connecting to the your server locally
```bash
openssl s_client -connect localhost:8201
```

### config/dev.secret.exs
If you want to do things like have a discord bot in development you don't want these details going into git. You can create a file `config/dev.secret.exs` where you can put these config details; the file must act like any other config file though is already ignored by gitignore.

## Creating your admin account
```elixir
MyApp.Account.create_user(%{
  name: "root",
  email: "root@localhost",
  password: "password",
  groups: ["admin"],
  permissions: ["admin"]
})
```

Editing it if you change something later
```elixir
user = MyApp.Account.get_user_by_email("root@localhost")
MyApp.Account.update_user(user, %{
  groups: ["admin"],
  permissions: ["admin"]
})
```

## Resetting your user password
When running locally it's likely you won't want to connect the server to an email account, as such password resets need to be done a little differently.

Run your server with `iex -S mix phx.server` and then once it has started up use the following code to update your password.

```elixir
user = MyApp.Account.get_user_by_email("root@localhost")
MyApp.Account.update_user(user, %{"password" => "your password here"})
```
