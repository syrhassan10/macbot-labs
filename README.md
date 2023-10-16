# macbot-labs


Commannds

```bash

xhost +local:docker
sudo docker run -it --network host -v /dev/:/dev/  --privileged -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix macbot/testimage:v1 bash
# or luxonis/depthai-ros:noetic-latest
export ROS_MASTER_URI=http://macbot09:11311/

```
