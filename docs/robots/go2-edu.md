# Unitree Go2 EDU

The Unitree Go2 EDU is a quadruped robot. Prepare the test area and control
device before switching it on: startup can involve the robot standing up.

The [startup instructions below](#startup-unitree-procedure) follow Unitree's
manual. We do not yet have a tested lab startup procedure; the
[proposed lab routine](#proposed-lab-startup-routine) is a draft to try with the
robot owner and then record here.

Unitree's ROS 2 tooling communicates with Go2 through SDK2 and Cyclone DDS.
The upstream project recommends Ubuntu 22.04 with ROS 2 Humble and includes
state, standing, and sport-mode examples for Go2. [Unitree ROS 2 support](https://github.com/unitreerobotics/unitree_ros2)

## Before first use

!!! danger "One person controls motion"
    Do not run a Unitree movement example, teleoperation program, or custom
    control node while somebody else has the app or handheld controller active.
    Pick one control path for each session. Keep the controller or the
    designated safe-stop control with the operator, not on a desk.

| Setting | Value / where to record it |
|---|---|
| Robot name / asset ID | `TBC` |
| Required Wi-Fi network | `Robotics-2.4Ghz` or `Robotics-5Ghz` |
| Robot IP address / hostname | `TBC` |
| Development computer | Researcher's own laptop |
| Unitree ROS 2 workspace | Set up on your laptop; record your workspace path |
| Network interface used by DDS | Your laptop's Wi-Fi interface connected to Robotics Wi-Fi; record its name |
| App/controller account owner | `TBC` |
| Approved safe-stop procedure | `TBC` |

Do not change the robot's Unitree account binding, reset it, change
network settings, or install an OTA update without the robot owner's approval.

## Startup - Unitree procedure

Source: Unitree's *Go2 User Manual*, **Instructions for use**, printed pages
9-10 (PDF pages 7-8):
[battery installation](https://static.generation-robots.com/media/Go2-User-Manual.pdf#page=7)
and [body placement and startup](https://static.generation-robots.com/media/Go2-User-Manual.pdf#page=8).
Unitree also publishes the [manual on its own website](https://marketing.unitree.com/article/en/Go2/User_Manual.html).

### 1. Check and fit the battery

Check the parts are sound and the camera and LiDAR are clean and unobstructed.
With Go2 on flat ground, insert the battery from the side with its power
button facing upwards. It should click into place; if it does not fit, check
the orientation rather than forcing it.

### 2. Set the starting posture

Place Go2 lying level, with its belly support pad flat on the ground. Fully
fold the lower legs; the four knees and feet should rest on the ground, with
no leg trapped underneath the body. Check the manual's placement diagram
before power-on and keep hands clear of the joints.

### 3. Switch on and wait

1. Briefly press the battery power button once.
2. Press it again and hold for **at least two seconds**.
3. Allow about **two minutes** for startup. The head indicator flashes green
   while starting and becomes steady green when ready, with the body level.

!!! warning "Allow room for startup movement"
    Keep the area clear throughout power-on. Go2 may stand during startup;
    do not hold or reposition its legs while they are powered.

### 4. Connect the app or controller

First-time app binding and optional handheld-controller pairing are separate
setup tasks. Follow Unitree's
[app instructions (printed pages 11-12)](https://static.generation-robots.com/media/Go2-User-Manual.pdf#page=9)
and [handheld-controller manual](https://marketing.unitree.com/article/en/Go2/Handheld_Remote_Control.html).
For subsequent sessions, reconnect the existing device/account; the lab's
choice is still to be recorded in the table above.

The lab network is [Robotics Wi-Fi](index.md#robotics-wi-fi): Go2 should be
connected to `Robotics-2.4Ghz` or `Robotics-5Ghz`. Use the same lab network on
the device running the app when connecting through Wi-Fi.

## Proposed lab startup routine

!!! info "Draft - not yet tested on the lab Go2"
    This is a proposed session workflow, not an established lab procedure.
    Try it with the robot owner, confirm the controller and stop controls on
    our robot, then replace the `TBC` entries above with the tested values.

1. Record the operator, date, planned experiment, and battery charge.
2. Set aside a clear, level test area, disconnect charging leads, and choose
   one person to operate the app or controller. Have an observer for the
   first movement test.
3. Confirm the operator knows the stop method for that control device, then
   complete the Unitree startup steps above.
4. Reconnect the chosen controller/app and check robot status. For a ROS 2
   experiment, follow the [laptop checks below](#connect-your-laptop-for-ros-2)
   after confirming Go2 and your laptop are connected to Robotics Wi-Fi and
   your laptop's workspace is configured.
5. Before starting the experiment, try a short, slow movement and a normal
   stop in the clear area. Record faults and finish with the
   [switching-off procedure](#switching-off-go2).

To make this the lab procedure, record the exact controller model, account
owner, connection steps, stop button sequence, and test-area location. Record
your laptop's ROS 2 workspace, network interface, and environment script
separately when your development setup is ready. Physical startup can be
completed with the app/controller before connecting a laptop.

## Connect your laptop for ROS 2

Researchers use their own laptops for robot development. Set up ROS 2 and
the Unitree packages on your laptop using the
[upstream installation instructions](https://github.com/unitreerobotics/unitree_ros2),
then join `Robotics-2.4Ghz` or `Robotics-5Ghz`. Confirm Go2 is also connected
to [Robotics Wi-Fi](index.md#robotics-wi-fi). Its IP address or hostname still
needs to be recorded above.

Run the following in your laptop's ROS 2 terminal. These example paths assume
your Unitree workspace is at `~/unitree_ros2`; use your actual workspace path
if it is elsewhere.

```bash title="Go2 ROS 2 environment - read-only checks"
source /opt/ros/humble/setup.bash
source ~/unitree_ros2/cyclonedds_ws/install/setup.bash

# Configure this script with your laptop's Robotics Wi-Fi interface.
source ~/unitree_ros2/setup.sh

# Safe checks: discover available ROS 2 interfaces and inspect motion state.
ros2 topic list
ros2 topic echo /sportmodestate --once
```

The upstream `setup.sh` selects the network interface used by Cyclone DDS;
the interface name can differ between researchers' laptops. If you see no
Go2 topics, first confirm both devices are connected to Robotics Wi-Fi and
that your script selects your laptop's Wi-Fi interface. Ask the robot owner
for help if communication still fails.
[Unitree network setup](https://github.com/unitreerobotics/unitree_ros2)

## Common modules

### Read robot state

Run these checks from the ROS 2 terminal on your laptop:

```bash
ros2 topic list
ros2 topic echo /sportmodestate --once
ros2 topic hz /sportmodestate
```

`/sportmodestate` is a useful high-level motion-state topic in Unitree's Go2
ROS 2 package. A changing rate from `ros2 topic hz` confirms that live state
messages are arriving without sending a motion command.

### Record a short bag

Record data only after you have confirmed the required topics and have enough
space in your laptop's home directory:

```bash
mkdir -p "$HOME/rosbags"
ros2 bag record -o "$HOME/rosbags/go2-state-$(date +%F-%H%M%S)" /sportmodestate
```

Press `Ctrl+C` to finish recording cleanly. Add other topics only after you
have checked their names and data rate; image and point-cloud topics can use
storage very quickly.

### Standing, sport mode, teleoperation, and custom control

Unitree supplies Go2 examples including `go2_stand_example` and
`go2_sport_client`. These can command physical movement. They are not suitable
as an unsupervised first test and are intentionally not presented here as
copy-and-run commands. Before an authorised motion test, confirm all of the
following:

- no app, remote, or other program is issuing competing commands;
- the robot has a clear, level test area;
- an observer is present and can stop the robot;
- the experiment owner has reviewed the exact source code and expected motion;
- the robot is not charging and its battery level is sufficient.

## Switching off Go2

Source: Unitree's *Go2 User Manual*, **Switching off Go2**,
[printed page 17 (PDF page 15)](https://static.generation-robots.com/media/Go2-User-Manual.pdf#page=15).

1. Bring Go2 to a stationary standing position on flat ground, with its body
   level, before requesting the lying posture.
2. Use the connected app/controller to put Go2 into the **prone (lying-down)
   state**. Wait until it has finished lowering itself and is resting on the
   ground.
3. Briefly press the battery power button once, then press it again and hold
   for **two seconds** to switch off.
4. Once powered off, arrange the legs and hip joints as shown in the
   [startup placement instructions](#2-set-the-starting-posture), ready for
   the next session. For long-term storage, remove the battery and follow
   the manual's packing instructions for the transport case.

!!! warning "Lie down before switching off"
    Unitree specifies the prone/damping state before power-off. Cutting power
    while Go2 is standing can make it fall heavily and damage the robot.

For a research session, also stop experiment programs and finish any ROS 2
bag recording cleanly. Hand control back to the chosen app/controller before
requesting the lying posture. These software handover steps are part of the
proposed lab workflow; the exact control method still needs to be confirmed
on our robot.

## When something is wrong

- If Go2 is moving unexpectedly, use the lab's designated stop procedure,
  keep clear, and do not start another control program.
- If it does not stand, has a red indicator, or shows an abnormal posture,
  power down only once it is safe and report the fault. Do not recalibrate
  joints as a first response.
- If ROS 2 cannot see live topics, check the approved network connection and
  DDS setup script before changing any configuration.
- Do not use factory reset to solve an experiment problem.
