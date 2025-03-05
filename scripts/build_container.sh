#!/usr/bin/env bash
# This is called from bin/deploy, you should not need to call it manually
sudo rm -rf _build/prod
docker buildx build --build-arg env=prod -t myapp:latest .
