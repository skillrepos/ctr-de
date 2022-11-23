# simple script to build images with buildah

# Check inputs
if [[ $# -lt 3 ]]; then
  echo 
  echo "  Invalid number of arguments supplied!"
  echo
  echo "  Usage:  buildah-roar.sh <registry> <release> <file>"
  echo
  echo "     <registry> = [ docker | quay ]"
  echo "     <release> = [ prod | test ]"
  echo "     <file> = [ war file to include for web app ]"
  echo
  exit -1
fi

[[ $1 =~ ^(docker|quay)$ ]] || { echo "Registry must be docker|quay";  exit -2; }
[[ $2 =~ ^(prod|test)$ ]] || { echo "Release must be docker|quay";  exit -2; }

echo "Building database image..."
start_time="$(date -u +%s)"

# Create a temp container from base db image
ctr1=$(buildah from $1.io/mysql:5.5.45)

# Copy in initialization data for the database
buildah copy $ctr1 docker-entrypoint-initdb-$2.d /docker-entrypoint-initdb.d/

# Set the entrypoint and starting command
buildah config --cmd '["/entrypoint.sh","mysqld"]' $ctr1

# Commit the final image
buildah commit $ctr1 roar-db:1.0.1

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo
echo "*** Total of $elapsed seconds to build db image"
echo

echo Building webapp image...
start_time="$(date -u +%s)"

# Create a temp container from base web imae
ctr2=$(buildah from $1.io/tomcat:7.0.65-jre7)

# Copy webapp into image
buildah copy $ctr2 $3 $CATALINA_HOME/webapps/roar.war

# Set the entrypoint and starting command
buildah config --cmd '["catalina.sh", "run"]' $ctr2

# Commit the final image
buildah commit $ctr2 roar-web:1.0.1

end_time="$(date -u +%s)"
elapsed="$(($end_time-$start_time))"
echo
echo "*** Total of $elapsed seconds to build web image"
echo
echo Done!
echo
echo List of new images follows:
echo
buildah images --format '{{.ID}} {{.Name}}:{{.Tag}} {{.Size}} {{.CreatedAtRaw}}' | grep roar | head -n2
echo
