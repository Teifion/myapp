# Setup
- Do ansible
- Upload favicon
```sh
scp priv/static/images/favicon.png deploy@server.com:/var/www/favicon.ico
```


# Troubleshooting
### Anything obvious in these?
```sh
sudo systemctl status myapp
sudo journalctl -u myapp -xn | less
```

### Is the myapp binary in place?
```sh
stat /apps/myapp/bin
```

### Database
```sh
# Does it exist?
psql -U myapp_prod

# Do you have the right connection credentials?
psql -U myapp_prod -h myapp4x.com -W
```

# Check the logs
```sh
cat /var/log/myapp/info.log
```

# Start it manually
```sh
sudo systemctl stop myapp

```
