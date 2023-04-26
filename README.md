# ARK

A Docker image for running an [ARK: Survival Evolved](https://store.steampowered.com/app/346110/ARK_Survival_Evolved/) dedicated linux server using [ark-server-tools](https://github.com/arkmanager/ark-server-tools).
This image has a focus on being run in a Kubernetes cluster, but was inspired by [NightDragon1/Ark-docker](https://github.com/NightDragon1/Ark-docker). 
If you're just looking to run a Docker-based ARK server container, you should probably use that project instead.

## What's unique about this project?

- Based on [nhalase/steamcmd](https://github.com/nhalase/steamcmd), which is in turn based on an `ubuntu:latest` image (Ubuntu tags `latest` to mean latest LTS release)
  - steamcmd is installed manually (but following standard conventions), and not via package manager
  - [su-exec](https://github.com/ncopa/su-exec) is installed
- Time zone can be configured using the `TZ` environment variable by any unprivileged user
- [main.cfg](./main.cfg) is completely empty because the intention is for `main.cfg` to be mounted as a ConfigMap/Secret via Kubernetes
  - It's still included here for easy Docker-only testing purposes
- CMDs passed to this Docker image via `docker run` will be passed along to `arkmanager start`
- crontab location is defined by the `ARK_CRONTAB` environment variable (make sure it's executable by your `UID`/`GID` user)
