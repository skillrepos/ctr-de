#!/usr/bin/env bash
#
ctr1=$(buildah from mysql:5.5.45)
buildah copy $ctr1 docker-entrypoint-initdb.d /docker-entrypoint-initdb.d/
buildah config --entrypoint '["/entrypoint.sh","mysqld"]' $ctr1
buildah commit $ctr1 roar-db:1.0.1

ctr2=$(buildah from tomcat:7.0.65-jre7)
buildah copy $ctr2 $1 $CATALINA_HOME/webapps/roar.war
buildah config --cmd '["catalina.sh", "run"]' $ctr2
buildah commit $ctr2 roar-web:1.0.1

