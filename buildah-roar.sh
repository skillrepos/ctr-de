# simple script to build images with buildah

ctr1=$(buildah from quay.io/bclaster/roar-db-test:v4)
buildah copy $ctr1 docker-entrypoint-initdb.d /docker-entrypoint-initdb.d/
buildah config --cmd '["/entrypoint.sh","mysqld"]' $ctr1
buildah commit $ctr1 roar-db:1.0.1

ctr2=$(buildah from docker.io/tomcat:7.0.65-jre7)
buildah copy $ctr2 $1 $CATALINA_HOME/webapps/roar.war
buildah config --cmd '["catalina.sh", "run"]' $ctr2
buildah commit $ctr2 roar-web:1.0.1

