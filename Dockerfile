FROM nvidia/cuda:9.0-base-ubuntu16.04

RUN apt update \
  && apt-get update \
  && apt install -y software-properties-common \
  && apt-get install -y vim curl

RUN apt-add-repository -y ppa:deadsnakes/ppa \
  && apt-get update \
  && apt-get install -y python3.6 python3-pip python-pip

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install tensorflow
RUN pip install keras
RUN pip install h5py

RUN apt-get install -y chrony ntpdate
RUN ntpdate -q ntp.ubuntu.com

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y ros-kinetic-desktop-full
RUN apt-get install -y ros-kinetic-rqt
RUN apt-get install -y wget
RUN ["/bin/bash", "-c", "echo 'source /opt/ros/kinetic/setup.bash' >> ~/.bashrc;", "source ~/.bashrc"]
RUN apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential \
  && rosdep init \
  && rosdep update

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list'
RUN wget http://packages.ros.org/ros.key -O - | apt-key add -

RUN pip install catkin_pkg

RUN ["bin/bash", "-c", "mkdir -p ~/catkin_ws/src"]
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash \
  && cd ~/catkin_ws \
  && catkin_make \
  && source devel/setup.bash \
  && cd src \
  && catkin_create_pkg object_recognition rospy std_msgs cv_bridge sensor_msgs"
RUN ["/bin/bash", "-c", "echo 'source /root/catkin_ws/devel/setup.bash' >> ~/.bashrc;", "source ~/.bashrc"]

WORKDIR /root/catkin_ws/src/object_recognition
ADD ./src/classify.py .
RUN chmod +x classify.py

WORKDIR /
RUN nohup roscore &
CMD tail -f /dev/null