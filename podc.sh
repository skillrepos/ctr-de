podman build -t roar-web:1.0.0 --build-arg warFile=roar.war -f Dockerfile_roar_web_image .
podman build -t roar-db:1.0.0 -f Dockerfile_roar_db_image  .
podman pod create --name roar-pod  -p 8087:8080 --network bridge
podman run --pod roar-pod  --name roar-web --ipc=private  -d roar-web:1.0.0
podman run --pod roar-pod  --env-file env.list  --ipc=private --name roar-db  -dt roar-db:1.0.0
