# Runs on-top of the pgsql-cluster-manager base image to install an appropriate test
# Postgres setup
FROM gocardless/pgsql-cluster-manager

# Install Postgres configuration, including an empty data directory
RUN rm -rf /var/lib/postgresql/9.4/main
ADD main.tar.gz /var/lib/postgresql/9.4/
COPY postgres/postgresql.conf postgres/pg_hba.conf /etc/postgresql/9.4/main/

# Set PGBouncer to trust mode on everything- we don't care about authentication in our
# tests
COPY pgbouncer/userlist.txt pgbouncer/pgbouncer.ini.template /etc/pgbouncer/
RUN cp -v /etc/pgbouncer/pgbouncer.ini.template /etc/pgbouncer/pgbouncer.ini

COPY corosync/authkey /etc/corosync/
COPY resource_agents/pgsql /usr/lib/ocf/resource.d/heartbeat/

COPY start-cluster.bash /bin/start-cluster

# Install support for https apt repos since Postgres ones now require it
#
# To do that, we need to temporarily move the Postgres one out the way
RUN mv /etc/apt/sources.list.d/pgdg.list /root/pgdg.list
RUN apt-get update && apt-get install apt-transport-https ca-certificates
RUN mv /root/pgdg.list /etc/apt/sources.list.d/pgdg.list

# Switch to apt-archive as Postgres repo has moved there
RUN sed -i 's/apt.post/apt-archive.post/' /etc/apt/sources.list.d/pgdg.list

# Install psmisc so we have killall to run pacemaker stop from init script
RUN apt-get update && apt-get install psmisc

EXPOSE 5432 6432 2379
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["bash", "-c", "while :; do sleep 1; done"]
