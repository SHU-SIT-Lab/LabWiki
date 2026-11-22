#!/usr/bin/env bash
# Care-O-bot 4 (cob4-24) terminal environment on the robot's b1 computer.
# Source this file; it does not start ROS nodes or move the robot.

source /opt/ros/kinetic/setup.bash
source "$HOME/josh_ws/devel/setup.bash"

# Hardware profile selected by cob_bringup/robot.launch.
export ROBOT=cob4-24

# 4114c is a map location, not an upstream cob_default_env_config profile.
# Navigation must receive this path explicitly through its map:= argument.
unset ROBOT_ENV
export COB24_MAP="$HOME/4114c/map.yaml"
