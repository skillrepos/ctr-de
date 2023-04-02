# Introduction to Kubernetes - optional labs

**Lab 1- Building Docker Images**

**Purpose: In this lab, we'll see how to build Docker images from Dockerfiles.**

1. Clear your console and switch into the directory for our docker work.
>
> **\$ clear**
>
> **\$ cd containers**
>

2.  Do an **ls** command and take a look at the files that we have in
    this directory.

>
> **\$ ls**
>

3.  Take a moment and look at each of the files that start with
    "Dockerfile". See if you can understand what's happening in them.
>
> **\$ cat Dockerfile_roar_db_image**
>
> **\$ cat Dockerfile_roar_web_image**
>

4.  Now let's build our docker database image. Type (or copy/paste) the
    following command: (Note that there is a space followed by a dot at
    the end of the command that must be there.)
>
> **\$ docker build -f Dockerfile_roar_db_image -t roar-db .**
>

5.  Next build the image for the web piece. This command is similar
    except it takes a build argument that is the war file in the
    directory that contains our previously built webapp.

    (Note the space and dot at the end again.)

>
> **\$ docker build -f Dockerfile_roar_web_image \--build-arg warFile=roar.war -t roar-web .**
>

6.  Now, let's tag our two images for our local registry (running on
    localhost, port 5000). We'll give them a tag of "1.0.0" as opposed to
    the default tag that Docker provides of "latest".

>
> **\$ docker tag roar-web localhost:5000/roar-web:1.0.0**
>
> **\$ docker tag roar-db localhost:5000/roar-db:1.0.0**
>

7.  Do a docker images command to see the new images you've created.

>
> **\$ docker images \| grep roar**
>

8. We need to port-forward to be able to access the registry easily. (You can just dismiss any dialogs that pop-up after you run this one.)

> 
> **\$ kubectl port-forward --namespace kube-system service/registry 5000:80 &**
>

9. Let's go ahead and push our images over to our local registry so
they'll be ready for Kubernetes to use.

>
> **\$ docker push localhost:5000/roar-web:1.0.0**
>
> **\$ docker push localhost:5000/roar-db:1.0.0**
>
>
<p align="center">
**[END OF LAB]**
</p>

**Lab 2 - Exploring and Deploying into Kubernetes**

**Purpose:** In this lab, we'll start to learn about Kubernetes and its
object types, such as nodes and namespaces. We'll also deploy a version
of our app that has had Kubernetes yaml files created for it.

1.  Before we can deploy our application into Kubernetes, we need to
    have appropriate Kubernetes manifest yaml files for the different
    types of k8s objects we want to create. These can be separate files
    or they can be combined. For our project, there are separate ones
    (deployments and services for both the web and db pieces) already
    setup for you in the **k8s** directory. Change into that
    directory and take a look at the yaml file there for the Kubernetes
    deployments and services.
>
> **\$ cd ../k8s**
>
> **\$ cat *.yaml**
>

2.  We're going to deploy these into Kubernetes into a namespace. Take a
    look at the current list of namespaces and then let's create a new
    namespace to use.
>
> **\$ kubectl get ns**
>
> **\$ kubectl create ns roar**
>

3.  Now, let's deploy our yaml specifications to Kubernetes. We will use
    the apply command and the -f option to specify the file. (Note the
    -n option to specify our new namespace.)
>
> **\$ kubectl -n roar apply -f .**
>
After you run these commands, you should see output like the following:

```console
deployment.extensions/roar-web created
service/roar-web created
deployment.extensions/mysql created
service/mysql created
```

4.  Now, let's look at the pods currently running in our "roar"
    namespace (and also see their labels).
>
> **\$ kubectl get pods -n roar \--show-labels**
>

5.  Next, let's look at the running application.  Run the command below.

> 
> **\$ kubectl port-forward -n roar svc/roar-web 8089 &**
>
![Port pop-up](./images/kint6.png?raw=true "Port pop-up")

6.  You should see a pop-up in your codespace that informs that `(i) Your application running on port 8089 is available.` and gives you a button to click on to `Open in browser`.  Click on that button. (If you don't see the pop-up, you can also switch to the `PORTS` tab at the top of the terminal, select the row with `8089`, and right-click and select `View in browser`.)

7.  What you should see in the browser is an application called **Apache Tomcat** running. Click at the end of the URL in the address bar and add the text `/roar/`.  Make sure to include the trailing slash.  Then hit enter and you should see the *roar* application running in the browser.

The complete URL should look something like
```console
https://gwstudent-cautious-space-goldfish-p7vpg5q55xx36944-8089.preview.app.github.dev/roar/
```
![Running app in K8s](./images/kint5.png?raw=true "Running app in K8s")

8.  Let's check the logs of the database pod to see what the application is doing there. 
    Run the command below to see the logs of the database pod:
>
> **\$ kubectl logs -n roar -l app=roar-db**
>

9.  To get the overall view (description) of what's in the pod and what's happening
    with it, we can also use the "describe" command. Run the command below.
>
> **\$ kubectl -n roar describe pod -l app=roar-db**
>
    Near the bottom of this output, notice the *Events* messages which describe major events associated with the pod.

10.  To demonstrate the deployment functionality in Kubernetes, let's delete one of the pods. With your cursor in your terminal in the codespace, right-click and select the `Split Terminal` option. This will add a second terminal side-by-side with your other one.

![Splitting the terminal](./images/kint7.png?raw=true "Splitting the terminal")

11.  In the left terminal, run a command to start a `watch` of pods in the roar namespace.
>
> **\$ kubectl get -n roar pods -w**
>
12. Now in the right terminal, enter a command to delete the database pod. Watch the activity in the left terminal as the old pod is removed and a new, different one created by the deployment. (You can tell its a different pod by looking at the end of the name.)
>
> **\$ kubectl delete -n roar pod -l app=roar-db**
>

<p align="center">
**[END OF LAB]**
</p>
