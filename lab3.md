
# 💾 Lab 3: Depth Camera Integration and Point Cloud Visualization

## GitHub Repository

{% embed url="https://github.com/septmacbot/macbot-deploy" %}

## Objectives


-   Learn how to set up and use a depth camera with ROS.
    
-   Generate a point cloud from depth images.
    
-   Create a transformation between the camera frame and the robot's base link frame.
    
-   Visualize camera data in RViz.



## Quick review of ROS 

### Nodes

Nodes are essentially running programs that use ROS to communicate with each other. In a robot, you could have one node controlling the wheels, another processing sensor data, and another handling high-level logic. These nodes are modular and are designed to perform specific tasks.

### Topics

Topics are named buses over which nodes exchange messages. A node sends out a message by publishing it to a specific topic, and nodes that are interested in that type of message subscribe to that topic. The Publish-Subscribe pattern allows for asynchronous communication between nodes.

#### Publishers and Subscribers

-   **Publishers** are nodes that send out messages to a topic.
-   **Subscribers** are nodes that receive messages from a topic.

![ROS Overview](ROS-Node-and-Topics-scheme.png)

## Depth AI Python Jetson Nano Setup 
##### This phase serves as a preliminary step, focusing on the configuration of your Jetson system to interface with the OAK-D cameras effectively. It also involves the installation of the DepthAI Python Library,  which is not related to ROS but is to verify the successful launch and functioning of the OAK-D camera system post-setup.

Open a terminal window and run the following commands:
```bash
#Add USB rules to your system

echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | sudo tee /etc/udev/rules.d/80-movidius.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

```bash
sudo apt update && sudo apt upgrade
sudo reboot now
```
Change the size of your SWAP. These instructions come from the `Getting Started with AI on Jetson <https://developer.nvidia.com/embedded/learn/jetson-ai-certification-programs>` from Nvidia:

```bash
# Disable ZRAM:
sudo systemctl disable nvzramconfig
# Create 4GB swap file
sudo fallocate -l 4G /mnt/4GB.swap
sudo chmod 600 /mnt/4GB.swap
sudo mkswap /mnt/4GB.swap
```
install `pip` and `python3` 

```bash
sudo -H apt install -y python3-pip
```
After that, install and set up virtual environment:
```bash
sudo -H pip3 install virtualenv virtualenvwrapper
```
#### How Virtual Environment Works

1.  **Isolation**: It isolates the Python interpreter, dependencies, libraries, and environment variables used within a specific project from the global interpreter.
    
2.  **Dependency Management**: It enables you to install Python libraries in the scope of the project rather than system-wide, thus avoiding version conflicts.
    
3.  **Switching Projects**: Virtual environments allow you to switch between different projects by activating or deactivating the corresponding environments, each with its own set of dependencies.

Add following lines to the bash script:

```bash
sudo vi ~/.bashrc

# Virtual Env Wrapper Configuration
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh
```
Save and reload the script by running the command `source ~/.bashrc`. Then create a virtual environment (in this example it's called `depthAI`).
  
```bash
mkvirtualenv depthAI_ve -p python3
```
**Note!** Before installing `depthai`, make sure you're in the virtual environment.

```bash

#Download and install the dependency package
sudo wget -qO- https://docs.luxonis.com/install_dependencies.sh | bash

#Clone github repository
git clone https://github.com/luxonis/depthai-python.git
cd depthai-python
```
Last step is to edit :code:`.bashrc` with the line:

```bash
echo "export OPENBLAS_CORETYPE=ARMV8" >> ~/.bashrc
```
Navigate to the folder with `depthai` examples folder, run `python3 install_requirements.py` and then run `python3 rgb_preview.py` to test out if your camera works.

![ROS Overview](depthai_pythonlib_1.png)
![ROS Overview](depthai_pythonlib_2.png)



## Docker  + ROS

Each tagged version has it's own prebuilt docker image. To download and run it:

```bash
xhost +local:docker
```

to enable GUI tools such as rviz or rqt.

Then
```bash
docker run -it -v /dev/:/dev/  --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix luxonis/depthai-ros:noetic-latest bash
```

-   `docker run`: The command to create and start a new Docker container.
    
-   `-it`: Run the container in interactive mode with a terminal.
    
-   `-v /dev/:/dev/`: Mounts the `/dev/` directory of the host to `/dev/` inside the Docker container. This is usually done to provide the container with access to device files of the host system, which would include USB interfaces.
    
-   `--privileged`: Grants additional privileges to this container, allowing it to have almost the same level of access to the host machine as native processes running on the host. This is often used for accessing hardware devices like USB ports.
    
-   `-e DISPLAY`: Sets the `DISPLAY` environment variable in the container, allowing graphical applications to display on the host's X server.
    
-   `-v /tmp/.X11-unix:/tmp/.X11-unix`: This allows you to run graphical applications inside the container and have their windows displayed on the host's X server.
    
-   `luxonis/depthai-ros:noetic-latest`: Specifies the Docker image to use, which in this case is the latest version of `depthai-ros` built for ROS Noetic.

## Running Depth-AI ROS Noetic Docker Image

OAK-D Cameras by Luxonis utilize the official luxonis Depth-AI ROS packages which only include support for ROS 2 Distros
and only ROS Noetic Distro from ROS 1.

The ROS Distro you have been using the past labs is ROS Melodic which is compatiable with the On-Board Jestson Nano Linux system ubuntu 18.04. 

Unfortunetly ROS Noetic is not compatiable with Ubuntu 18.04 and thus can not be used. However we can use Docker Images to solve this problem !

### How Docker Helps

Docker allows you to create a containerized environment where you can run software independently of your host system. This means you can set up an Ubuntu 20.04 container with ROS Noetic installed, allowing you to use the Luxonis Depth-AI ROS packages without affecting your host system running Ubuntu 18.04.


```bash

xhost +local:docker
sudo docker run -it --network host -v /dev/:/dev/  --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix luxonis/depthai-ros:noetic-latest bash
```

once you are inside the docker container run the following 

```bash
roslaunch depthai_examples  stereo_node.launch
```
![ROS Overview](ros_example.png)


you can look inside the other depthai_* ROS Packages and attempt to run them. Please note some of them won't work. i.e. rtabmap launch files won't work as the package is not installed as part of the container. You can apt-get install it and other repos however, once containers are closed all the work inside of them are lost (unless you save current container into a new image).

Some of the launch files require a lot of memory for processing and can crash the jetson nano.
## How do we communicate between nodes in the docker container and with the master nodes in our host machine that run the robot from previous labs.

The ROS_MASTER_URI environment variable specifies the address where the ROS Master is running. In ROS, the Master is responsible for facilitating communication between different nodes. Nodes register themselves with the Master and inquire about other nodes they want to communicate with. Once two nodes know about each other through the Master, they can communicate directly.

### Setting ROS_MASTER_URI 

When you set `export ROS_MASTER_URI=http://macbot09:11311/` both inside the Docker container and on the host machine, you are telling ROS nodes in both environments to register with and look for other nodes at the Master running on http://macbot09:11311/. This allows nodes inside the container to communicate with nodes outside of the container, provided they are reachable over the network.

### --network host in Docker
The --network host option in Docker allows the container to share the host machine's network stack. This effectively gives the container full access to the same network interfaces as the host, meaning it can connect to the localhost of the host machine.

Here's how it all connects:

Host ROS Master: You run roscore on your host machine. This starts the ROS Master at a specific URI, say http://macbot09:11311/.

Docker Container: You start a Docker container with the --network host option. This means any network activity in the container is as if it is coming from the host machine itself.

Setting ROS_MASTER_URI: Inside the Docker container, you set ROS_MASTER_URI to http://macbot09:11311/, the same as the host machine.


Now exit the container by entering `exit` into the terminal

in a new tab run `roscore`. This will start up a ROS Master 

![ROS Overview](roscore_host.png)


Now  re run these commands

```bash

xhost +local:docker
sudo docker run -it --network host -v /dev/:/dev/  --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix luxonis/depthai-ros:noetic-latest bash
```

once you are inside the docker container run the following 

```bash
roslaunch depthai_examples  stereo_node.launch
```

![ROS Overview](docker_ros_stereo_node_start.png)


Create a new tab (original host terminal should be opened)

run 
```bash
rosnode list

rostopic list
```

![ROS Overview](rosnodelist_host.png)

The ros master on your host machine (Jetson nano) should be able to see and read the depthai-ros-neotic nodes from the docker container. Paste a screenshot in your report

## Listing Docker containers
```
sudo docker images
```
