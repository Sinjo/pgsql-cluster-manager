# Generates an image that can be used as a base for dependencies
FROM ubuntu:trusty

ENV POSTGRESQL_VERSION=9.4 PGBOUNCER_VERSION=1.9.0-*
RUN set -x \
    && apt-get update \
    && apt-get install -y \
        software-properties-common \
        build-essential \
        curl \
        ruby-dev \
        wget \
        apt-transport-https \
        ca-certificates \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && dpkg -i dumb-init_*.deb && rm dumb-init_*.deb \
    && gem install bundler -v '~> 1.0.0' \
    && add-apt-repository ppa:gophers/archive \
    && echo "deb https://apt-archive.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main\ndeb https://apt-archive.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg 9.4" > /etc/apt/sources.list.d/pgdg.list \
    # This is awful, and should only be run on networks where we trust DNS, but
    # the LE root key isn't in this ancient ubuntu and their cross-signed intermediate
    # expired
      && curl --insecure --silent -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update -y \
    && apt-get install -y \
        postgresql-"${POSTGRESQL_VERSION}" \
        pgbouncer="${PGBOUNCER_VERSION}" \
        corosync \
        pacemaker \
        golang-1.9-go \
    && ln -s /usr/lib/go-1.9/bin/go /usr/bin/go \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV ETCD_VERSION=v3.2.6
RUN curl \
      -L https://storage.googleapis.com/etcd/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
      -o /tmp/etcd-linux-amd64.tar.gz && \
  mkdir /tmp/etcd && \
  tar xzvf /tmp/etcd-linux-amd64.tar.gz -C /tmp/etcd --strip-components=1 && \
  sudo mv -v /tmp/etcd/etcd /tmp/etcd/etcdctl /usr/bin/ && \
  rm -rfv /tmp/etcd-linux-amd64.tar.gz /tmp/etcd
