FROM ubuntu:14.04.3
MAINTAINER https://hub.docker.com/r/michaelhenkel/openstack/

ENV OPENSTACK_VERSION liberty

ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  language-pack-en \
  ubuntu-cloud-keyring \
  && locale-gen en_US \
  && echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/liberty main" > /etc/apt/sources.list.d/cloudarchive-liberty.list \
  && apt-get update && apt-get install -y --no-install-recommends \
  apt-transport-https \
  ca-certificates \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN env --unset=DEBIAN_FRONTEND
COPY openstack-config /

CMD ['/bin/sh']
