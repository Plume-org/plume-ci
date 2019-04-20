# Plume CI

Experimental script to automatically deploy test instance for each proposed PR.

To execute:

```
sudo docker pull plumeorg/plume-buildenv:v0.0.5 # First time only
sudo ./bash.sh
```

## How does it work?

- The sqlite build is uploaded to the joinplu.me server for each new PR (by Circle CI)
- This script waits for new uploads.
- When a new build is uploaded, this script starts a Docker container that runs it
- A Caddyfile is generated to make the test instances accessible from the outside