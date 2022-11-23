# simple script to build images with buildah

ctr1=$(buildah from docker.io/mysql:5.5.45)

if [ -n "$1" ] && [ "$1" = "test" ]; then
  $src-data-dir = "docker-entrypoint-initdb-test.d"
elif [ -n "$1" ] && [ "$1" = "prod" ]; then
  $src-data-dir = "docker-entrypoint-initdb-prod.d"
else
  echo "Missing data type parameter!"
  exit -1
fi

buildah copy $ctr1 docker-entrypoint-initdb.d /$src-data-dir/
buildah config --cmd '["/entrypoint.sh","mysqld"]' $ctr1
buildah commit $ctr1 roar-db:1.0.1

ctr2=$(buildah from docker.io/tomcat:7.0.65-jre7)
buildah copy $ctr2 $1 $CATALINA_HOME/webapps/roar.war
buildah config --cmd '["catalina.sh", "run"]' $ctr2
buildah commit $ctr2 roar-web:1.0.1

