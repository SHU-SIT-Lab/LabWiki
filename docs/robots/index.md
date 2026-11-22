# Lab robots

This section covers the lab's physical robots. It starts with the procedures
that apply to every platform, followed by platform-specific runbooks for
[Care-O-bot 4](care-o-bot-4.md) and [Unitree Go2 EDU](go2-edu.md).

## Before you start any robot

!!! danger "Physical robot safety"
    Only trained, authorised users may operate a physical robot. Keep a clear
    test area, identify the emergency-stop or safe-stop control before power
    on, and make sure that another person can intervene for the first motion
    test of a session. Do not run an unfamiliar launch file, autonomy stack,
    or example program on a physical robot.

Use this checklist before every session:

1. Book the robot and tell people nearby that testing is about to begin.
2. Inspect the robot, battery, charger, cables, and test area. Do not use a
   damaged robot or battery.
3. Remove charging leads before requesting motion.
4. Keep people, bags, chairs, and other obstacles outside the robot's planned
   path and arm reach.
5. Confirm that a trained operator has the control device and that you know
   how to stop the robot.
6. Start with a read-only status check or simulation. Test physical movement
   slowly and with a spotter.

## Stop, emergency stop, and power off are different

| Action | When to use it | What to do next |
|---|---|---|
| **Stop a task** | The software is doing the wrong thing but there is no immediate hazard | Cancel the task and check the command or goal before retrying |
| **Emergency/safe stop** | There is a risk of collision, a person enters the test area, or the robot behaves unexpectedly | Stop motion immediately; do not release or reset it until the area is safe and the cause is understood |
| **Controlled shutdown** | The session has finished | Park or make the robot prone as required, stop software cleanly, then follow the platform shutdown procedure |

An emergency stop is not a normal shutdown mechanism. After any emergency
stop, record what happened and ask the robot owner for help if the cause is
unclear.

## Robotics Wi-Fi

**Robotics Wi-Fi** is the shared lab network for all robots. The agreed
network names are:

- `Robotics-2.4Ghz`
- `Robotics-5Ghz`

Each robot should be connected to Robotics Wi-Fi. Normally, connect your own
laptop to one of these networks when working with a robot. Choose a network
supported by the device and ask the robot owner for the Wi-Fi credentials or
help connecting a robot.

For **Care-O-bot 4**, the recommended laptop connection is the robot's
[built-in Wi-Fi](care-o-bot-4.md#connect-your-laptop). Its computers have
static IP addresses on that network, which makes access simpler. Care-O-bot
is also connected to Robotics Wi-Fi and can be accessed through it.

## Working with robot software

Researchers use their own laptops to connect to the robots and run development
tools. The lab's AI workstation is used for AI model work. Follow the relevant
robot guide for the connection and software setup on your laptop; workspace
paths and network-interface names may differ between researchers.

Keep experiments reproducible and easy to hand over:

- Store code in Git and record the branch or commit used for a run.
- Save bag files, maps, and logs with the date and experiment name.
- Keep one person responsible for motion commands at any one time.
- Start with sensors and state topics before enabling teleoperation,
  navigation, or manipulation.
- Do not update firmware, recalibrate hardware, change network settings, or
  factory-reset a robot without the robot owner's approval.

## Platform runbooks

| Robot | Best first task | Software interface |
|---|---|---|
| [Care-O-bot 4](care-o-bot-4.md) | Bring up the dashboard and inspect robot state in RViz | ROS 1 / Care-O-bot stack |
| [Unitree Go2 EDU](go2-edu.md) | Follow Unitree startup and check status with the app/controller | App/controller; ROS 2 development uses Unitree SDK2 and Cyclone DDS |

## Report a problem

If a robot is damaged, behaves unexpectedly, has a recurring fault, or has
been emergency-stopped for an unknown reason, stop using it and contact
**Josh Bamforth** at [josh.bamforth@shu.ac.uk](mailto:josh.bamforth@shu.ac.uk).

Include the robot name, time, operator, what it was doing, and any relevant
terminal output, ROS log, or bag file.
