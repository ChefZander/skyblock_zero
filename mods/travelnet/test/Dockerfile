ARG ENGINE_VERSION=5.6.0
FROM registry.gitlab.com/minetest/minetest/server:${ENGINE_VERSION}

USER root
RUN apk add git &&\
    mkdir -p /root/.minetest/worlds/world/worldmods/ &&\
    git clone https://github.com/BuckarooBanzay/mtt /root/.minetest/worlds/world/worldmods/mtt

# old file-based storage to test migration
COPY ./mod_travelnet.data.json /root/.minetest/worlds/world/mod_travelnet.data

ENTRYPOINT minetestserver --config /minetest.conf