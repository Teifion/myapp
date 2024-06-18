#!/usr/bin/env bash
docker run -v $(pwd):/opt/build --rm -it myapp:latest /opt/build/bin/build

