# Setup folders
echo "Starting release"

# Remove previous release
rm -rf /tmp/myapp_release
mkdir -p /tmp/myapp_release
cd /tmp/myapp_release

echo "Decompressing"
tar mxfz /home/deploy/releases/myapp_stable.tar.gz

echo "Backup existing"
rm -rf /apps/myapp_backup
mv /apps/myapp /apps/myapp_backup

echo "Stopping service"
/apps/myapp_backup/bin/myapp stop

echo "Remove existing binary"
sudo rm -rf /apps/myapp

echo "Relocate binary"
cp -r /tmp/myapp_release/opt/build/_build/prod/rel/myapp /apps

echo "Rotate logs"
rm /var/log/myapp/error_old.log
rm /var/log/myapp/info_old.log

cp /var/log/myapp/error.log /var/log/myapp/error_old.log
cp /var/log/myapp/info.log /var/log/myapp/info_old.log

echo "Clear logs"
> /var/log/myapp/error.log
> /var/log/myapp/info.log

# Settings and vars
sudo chmod o+rw /apps/myapp/releases/0.0.1/env.sh
cat /apps/myapp.vars >> /apps/myapp/releases/0.0.1/env.sh

# Reset permissions
sudo chown -R deploy:deploy /apps/myapp
sudo chown -R deploy:deploy /var/log/myapp

echo "Starting service"
sudo systemctl restart myapp.service
