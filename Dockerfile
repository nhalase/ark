FROM nhalase/steamcmd:latest AS build-stage
ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="nhalase"
LABEL description="A Docker image for running an ARK: Survival Evolved dedicated linux server using ark-server-tools."

# Bootstrapping variables
# Best practice is to not use uid/gid under 10000
ENV UID=10000 \
    GID=10001 \
    TZ=UTC \
    SESSIONNAME="ARK Docker" \
    SERVERMAP="TheIsland" \
    SERVERPASSWORD="" \
    ADMINPASSWORD="adminpassword" \
    MAX_PLAYERS=60 \
    ARKCLUSTERID=cluster1 \
    UPDATEONSTART=1 \
    BACKUPONSTART=1 \
    CLIENTPORT=7777 \
    SERVERPORT=7778 \
    STEAMPORT=27015 \
    RCONPORT=32330 \
    ENABLERCON=true \
    BACKUPONSTOP=1 \
    WARNONSTOP=1 \
    ARK_CRONTAB=/etc/cron.d/ark-crontab

RUN set -x \
  && if [ ${CLIENTPORT} != $((${SERVERPORT} - 1)) ]; then echo "CLIENTPORT must be exactly 1 less than SERVERPORT" && exit 2; fi \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends --no-install-suggests \
      perl-modules \
      curl \
      lsof \
      libc6-i386 \
      lib32gcc-s1 \
      bzip2 \
      perl \
      rsync \
      sed \
      tar \
      findutils \
      coreutils \
      cron \
  # Install arkst
  && git config --global advice.detachedHead false \
  && git clone -b $(git ls-remote --tags https://github.com/arkmanager/ark-server-tools.git | awk '{print $2}' | grep -v '{}' | awk -F"/" '{print $3}' | tail -n 1) --single-branch --depth 1 https://github.com/arkmanager/ark-server-tools.git /home/steam/ark-server-tools \
  && cd /home/steam/ark-server-tools \
  && bash netinstall.sh steam --bindir=/usr/bin \
  && (crontab -l 2>/dev/null; echo "* 3 * * Mon yes | arkmanager upgrade-tools >> /ark/log/arkmanager-upgrade.log 2>&1") | crontab - \
  && mkdir /ark \
  && chown steam /ark && chmod 755 /ark \
  # Clean up
  && apt-get remove --purge --auto-remove -y \
  && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

FROM build-stage AS arkst

COPY --chown=steam:steam --chmod=644 arkmanager.cfg /etc/arkmanager/arkmanager.cfg
COPY --chown=steam:steam --chmod=644 main.cfg /etc/arkmanager/instances/main.cfg
COPY --chown=steam:steam --chmod=744 cron-test.sh /home/steam/cron-test.sh
COPY --chown=root:root --chmod=755 docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
COPY --chown=root:root --chmod=755 run-ark.sh /usr/bin/run-ark.sh
COPY --chown=root:root --chmod=755 ark-healthcheck.sh /usr/bin/ark-healthcheck.sh
COPY --chown=root:root --chmod=666 crontab $ARK_CRONTAB

EXPOSE ${RCONPORT}/tcp
EXPOSE ${STEAMPORT}/udp ${CLIENTPORT}/udp ${SERVERPORT}/udp

VOLUME /ark

WORKDIR /ark

ENTRYPOINT [ "docker-entrypoint.sh", "run-ark.sh" ]

HEALTHCHECK --interval=600s --timeout=60s --retries=2 --start-period=600s CMD ark-healthcheck.sh
