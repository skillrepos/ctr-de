<div align="center">

**Containers Demystified**
A hands-on approach to understanding container mechanics, standards, and tooling.  Includes Docker, Podman, and Buildah

**Class Labs**
Version 2.0 by Brent Laster for Tech Skills Transformations LLC

04/01/2023
</div>


**Lab 1 - Creating Images

**Purpose:  In this lab, we’ll see how to do basic operations like build with images.

<details>
<summary>** Lab 1 - Creating Images - click to expand</summary>

1. If you haven't already, clone down the ctr-de repository from GitHub.

>
>       git clone https://github.com/skillrepos/ctr-de
>

2. Switch into the directory for our docker work.

>
>       cd roar-docker
>

3. Do an ls command and take a look at the files that we have in this directory.

>
>       $ ls
>

4. Take a moment and look at each of the files that start with “Dockerfile”.  See if you can understand what’s happening in them.

>
>       $ cat Dockerfile_roar_db_image
>       $ cat Dockerfile_roar_web_image
>          

5. Now let’s build our docker database image.  Type (or copy/paste) the following command: (Note that there is a space followed by a dot at the end of the command that must be there.)

>
>       $ docker build -f Dockerfile_roar_db_image -t roar-db .
>

6. Next build the image for the web piece.   This command is similar except it takes a build argument that is the war file in the directory that contains our previously built webapp.
(Note the space and dot at the end again.)

>
>       $ docker build -f Dockerfile_roar_web_image --build-arg  warFile=roar.war -t roar-web .
>

7. Now, let’s tag our two images with your user name for the docker.io or quay.io repositories. We’ll give them a tag of “v1” as opposed to the default tag that Docker provides of “latest”.

>
>       $ docker tag roar-web <your registry username>/roar-web:v1
>       $ docker tag roar-db <your registry username>/roar-db:v1
>
       
8. Do a docker images command to see the new images you’ve created.

>
>       $ docker images | grep roar
>
	
</details>	
<p align="center">	
**END OF LAB
</p>



**Lab 2 – Composing images together

**Purpose: In this lab, we’ll see how to make multiple containers execute together with docker compose and use the docker inspect command to get information to see our running app.

1.	Take a look at the docker compose file for our application and see if you can understand some of what it is doing.
$ cat docker-compose.yml

2.	Run the following command to compose the two images together that we built in lab 1.
$ docker-compose up

3.	You should see the different processes running to create the containers and start the application running.  Take a look at the running containers that resulted from this command.

Note: We’ll leave the processes running in the first session, so open a second command prompt/terminal emulator and enter the command below.

$ docker ps | grep roar


4.	Make a note of the first 3 characters of the container id (first column) for the web container (row with roar-web in it).  You’ll need those for the next step.

5.	Let’s find the web address so we can look at the running application.  To do this, we will search for the information via a docker inspect command.  Enter this command in the second terminal session, substituting in the characters from the container id from the step above for “<container id>” - the one for roar-web.   

(For example, if the line from docker ps showed this:

237a48a2aeb8        roar-web         "catalina.sh run"        About a minute ago   Up About a minute   0.0.0.0:8089->8080/tcp   

then <container id> could be “237”. Also note that “IPAddress” is case-sensitive.)

Make a note of the url that is returned.

$ docker inspect <container id> | grep IPAddress



6.	Open a web browser and go to the url below, substituting  in the ip address from the step above for “<ip address>”. (Note the :8080 part added to the ip address)

           http://<ip address>:8080/roar/


7.	You should see the running app on a screen like the following:

 

END OF LAB


Lab 3 – Debugging Docker Containers

Purpose: While our app runs fine here, it’s helpful to know about a few commands that we can use to learn more about our containers if there are problems.  

1.	Let’s get a description of all of the attributes of our containers.  For these commands, use the same 3 character container id you used in step 2.  

Run the inspect command.   Take a moment to scroll around the output.

$ docker inspect <container id> 

2. Now, let’s look at the logs from the running container.  Scroll around again and look at the output.  

$ docker logs <container id> 



3. While we’re at it, let’s look at the history of the image (not the container).

	$ docker history roar-web


4. Now, let’s suppose we wanted to take a look at the actual database that is being used for the app. This is a mysql database but we don’t have mysql installed on the VM.  So how can we do that?  Let’s connect into the container and use the mysql version within the container.  To do this we’ll use the “docker exec” command.  First find the container id of the db container.

$ docker ps | grep roar-db


5. Make a note of the first 3 characters of the container id (first column) for the db container (row with roar-db in it).  You’ll need those for the next step.

6.  Now, let’s exec inside the container so we can look at the actual database.

	$ docker exec -it <container id> bash

Note that the last item on the command is the command we want to have running when we get inside the container – in this case the bash shell.

	
7.  Now, you’ll be inside the db container.   Check where you are with the pwd command and then let’s run the mysql command to connect to the database.  (Type these at the /# prompt.  Note no spaces between the options -u and -p and their arguments. You need only type the part in bold.)

	root@container-id:/# pwd
	root@container-id:/# mysql -uadmin -padmin registry


(Here -u and -p are the userid and password respectively and registry is the database name.)


8.  You should now be at the “mysql>” prompt.   Run a couple of commands to see what tables we have and what is in the database. (Just type the parts in bold.)

		mysql> show tables;
		mysql> select * from agents;


9. Exit out of mysql and then out of the container.

mysql> exit
root@container-id:/# exit


10. Let’s go ahead and push our images over to our local registry so they’ll be ready for Kubernetes to use.
$ docker push localhost:5000/roar-web:v1
$ docker push localhost:5000/roar-db:v1

11. Since we no longer need our docker containers running or the original images around, let’s go ahead and get rid of them with the commands below.

(Hint:  docker ps | grep roar  will let you find the ids more easily)

		Stop the containers

		$ docker stop <container id for roar-web>
		$ docker stop <container id for roar-db>

	Remove the containers

		$ docker rm <container id for roar-web>
		$ docker rm <container id for roar-db>

	Remove the images

		$ docker rmi -f roar-web
		$ docker rmi -f roar-db

	
END OF LAB

Lab 4:  Mapping Docker images and containers with the filesystem

Purpose: In this lab, we'll explore how layers, images and containers are actually mapped and stored in the filesystem.

1.  First, we need to access the underlying storage area for Docker.  If you are running Docker on a Linux machine, you can open a terminal session to "/var/lib/docker".

If you are on a Windows or Mac system and have Docker Desktop installed, run the following command in a terminal.

$ docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh
 
Now you should be able to change to the /var/lib/docker directory and see the files in that structure.

2.  In another terminal session, let's run an interactive container based off of Ubuntu.

$ docker run -ti ubuntu:18.04 bash

3.  After pulling down an instance of the image, it will be started running for you and you'll be inside the image.  Let's make some simple changes so we can see how these are represented and stored in the underlying file system.  We'll delete one file, create a second one and then exit the container.

# rm /etc/environment
# echo  new > /root/newfile.txt
# exit

4. Find the first 4 characters of the ubuntu container you were working with.  You can either get it from the previous steps or you can use a command like the one below to find it.

$ docker ps -a | grep ubuntu

5. Install the "jq" tool if you don't have it from https://stedolan.github.io/jq/

6. Run a docker inspect command to find the underlying filesystem directories for the layers - using the first 4 characters from the container id and the jq tool to get the "graphdriver" data.

$ docker inspect <first 4 chars of container id> | jq '.[0].GraphDriver.Data'


7. You should see output like the following.  Take note of the value for "UpperDir".  Select that and copy it.

{
  "LowerDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc-init/diff:/var/lib/docker/overlay2/4d037a0e2bb0f50d031382246c8374382fdd126b57960ff99d4b4c9be04cffd2/diff",
  "MergedDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/merged",
  "UpperDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/diff",
  "WorkDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/work"
}


8. In the other terminal window, where you are in the /var/lib/docker directory, do an "ls" of that directory to see what's in the Docker filesystem location.

$ ls <UpperDir path value copied from previous step>

The results should look something like this - showing the two top directories.

/ # ls /var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/diff
etc   root


9.  Now, take a look at the "etc" directory and you should see the file that was removed. 

$ ls <UpperDir path value copied from previous step>/etc

The results should look something like this showing the removed file.

/ # ls /var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/diff/etc
environment

10.  Next, look at the "root" directory and you should see the file that was created. 

$ ls <UpperDir path value copied from previous step>/root

The results should look something like this showing the added file.

/ # ls /var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/diff/root
newfile.txt


11. If you want to see where the original image is stored, grab the second path under the "LowerDir" section (after the "init/diff:" piece).  It is highlighted below.

{
  "LowerDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc-init/diff:/var/lib/docker/overlay2/4d037a0e2bb0f50d031382246c8374382fdd126b57960ff99d4b4c9be04cffd2/diff",
  "MergedDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/merged",
  "UpperDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/diff",
  "WorkDir": "/var/lib/docker/overlay2/c19f1aa7797551da6701cfe5bb716665189d7191e4bc27ba503e6eb1d3a864cc/work"
}

12. You can do an "ls" on the path copied from the previous step and you'll see the original starting layer for the container.  You can also look at the "etc" and "root" directories to see the original state of those without the changes we made.

$ ls <path value from 2nd part of LowerDir copied from previous step>

$ ls <path value from 2nd part of LowerDir copied from previous step>/root

$ ls <path value from 2nd part of LowerDir copied from previous step>/etc






Lab 5 - Working with Podman

Purpose: In this lab, we'll get a chance to work with Podman, an alternative to Docker that also includes the abilities to group and work with containers in "pods".

1. If you haven't already, go ahead and install podman according to the instructions for your platform. See instructions at https://podman.io/getting-started/installation

2. On non-linux machines, you can run podman via a container or via the podman virtual machine. The command to run via a container is shown in part A below.  If you choose to use the virtual machine, you will need to do the two instructions shown in part B below.

A. Running in a container

$ docker run -it --device /dev/fuse:rw --privileged -v <working dir>:/build quay.io/podman/stable bash

B. Running with the podman virtual machine. Follow the instructions to download the machine.  Then run it via the two commands below.  

$ podman machine init
$ podman machine start

3. Check that podman is installed and responding.

$ podman version

4. Now that you have podman installed, clone down the repository for us to work with in building images and then change into the directory with the docker content.

$ git clone https://github.com/skillrepos/ctr-de
$ cd ctr-de

4. Now, build the two images (the web one and the database one) that we need for our application. Note that the syntax for podman is just like the syntax for Docker. Afterwards, you can see the images with podman.

$ podman build -t roar-web:1.0.0 --build-arg warFile=roar.war -f Dockerfile_roar_web_image .

$ podman build -t roar-db:1.0.0 -f Dockerfile_roar_db_image  .

$ podman images


5. Now let's create a pod. 

$ podman pod create --name roar-pod  -p 8087:8080 --network bridge

6. Next, we'll list the pod we have and then inspect it to look at it closer.

$ podman pod ls

$ podman inspect roar-pod

7.  Notice the inspect lists one container at the bottom.  Let's look closer at what that container is.

$ podman ps -a --pod

8. Add the web image as a container to the pod.

$ podman run --pod roar-pod  --name roar-web  -d roar-web:1.0.0

9. Finally, we'll add the database image as a container to the pod.

$ podman run --pod roar-pod  -e MYSQL_USER="admin" -e MYSQL_PASSWORD="admin" -e MYSQL_DATABASE="registry" -e MYSQL_ROOT_PASSWORD="root+1"  --name roar-db  -dt roar-db:1.0.0

10. You can now see the containers running in the pod.

$ podman inspect roar-pod

11. Now you can open up the url below in a browser and see the application running.

http://localhost:8087/roar

 


Lab 6: Working with Buildah

In this lab, we'll work with the container build and management tool Buildah.

1. If you are running on a Linux system or VM, you can follow instructions at https://github.com/containers/buildah/blob/main/install.md  to install Buildah.  If you are running with Docker Desktop on a Mac or Windows system, you can run it via a Docker container.

2. When you run the Docker container, mount the area where you have the ctr-de directory available - indicated by the <working dir> in step 3.

3. Run the command below to access buildah via a container.

$ docker run -it --device /dev/fuse:rw --privileged -v <working dir>:/build quay.io/buildah/stable bash

4. If you are running on a linux system, cd to the ctr-de directory.

5. If you're running in a container, you'll now be in the container with access to buildah. Go to the build directory that you mounted into the container. And run the command below to produce new images using the bash script. After the images are created, you should be able to see them via the "buildah images" command.

$ cd /build (if in the container)
$ cd ctr-de (if in linux)

6.  Now, run the bash script that will use buildah to build the images instead of the Dockerfiles.  Also, we need to pass in the built deliverable to be pulled in for the webapp. That's what roar.web is.

$ bash ./buildah-roar.sh roar.web
$ buildah images

7. For this next step, you will need your docker.io userid or your quay.io userid. Login to one of these using the buildah login command and your username/password.

$ buildah login docker.io  -OR-  $ buildah login quay.io

8. After logging in to the registry, tag your images with your username appropriately.  

$ buildah tag <roar-web image> for <userid>/roar-web
$ buildah tag <roar-db image> for <userid>/roar-db

9. Push the images out to the registry.

$ buildah push <userid>/roar-web
$ buildah push <userid>/roar-db
10. Exit out of the container so you're back to being able to access podman.

$ exit

11. Use podman to pull the updated db image you just pushed.

$ podman pull <userid>/roar-db

12. Now, we'll use podman to remove the old container from the pod and replace it with the new one.

$ podman container rm <container name>
$ podman container run <new container name> --pod

13. Refresh the application in the browser and you should see a version of the app running with test data.


![image](https://user-images.githubusercontent.com/82771267/229325653-8ec59ca3-f40a-4cdb-b194-a1ceface655f.png)


<p align="center">
**[END OF LAB]**
</p>
