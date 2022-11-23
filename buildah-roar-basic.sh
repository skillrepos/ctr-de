# simple script to build images with buildah

# Create a temp container from base db image
ctr1=$(buildah from $1.io/mysql:5.5.45)

# Copy in initialization data for the database
buildah copy $ctr1 docker-entrypoint-initdb-$2.d /docker-entrypoint-initdb.d/

# Set the entrypoint and starting command
buildah config --cmd '["/entrypoint.sh","mysqld"]' $ctr1

# Commit the final image
buildah commit $ctr1 roar-db:1.0.1

# Create a temp container from base web imae
ctr2=$(buildah from $1.io/tomcat:7.0.65-jre7)

# Copy webapp into image
buildah copy $ctr2 $3 $CATALINA_HOME/webapps/roar.war

# Set the entrypoint and starting command
buildah config --cmd '["catalina.sh", "run"]' $ctr2

# Commit the final image
buildah commit $ctr2 roar-web:1.0.1


