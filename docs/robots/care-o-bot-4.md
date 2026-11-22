# Care-O-bot 4

Care-O-bot 4 is a mobile manipulation platform. It combines a mobile base,
torso, arm, gripper, and perception hardware, so startup is more than simply
turning on a computer. Treat its first motion after startup as a supervised
test.

## Before first use

!!! danger "Do not guess the robot configuration"
    Care-O-bot installations differ in their computer names, ROS version,
    robot profile, map, calibration, and launch packages. The hardware and
    software values below have been checked on the lab robot. Do not substitute
    another Care-O-bot profile or an example map from the internet.

| Setting | Lab value to record |
|---|---|
| Robot name / asset ID | `cob4-24` |
| Robot computer hostname | `b1` (use the local SSH alias `cob24`) |
| Recommended laptop connection | Care-O-bot's built-in Wi-Fi; SSID `TBC` |
| Alternative laptop connection | `Robotics-2.4Ghz` or `Robotics-5Ghz` |
| `b1` static IP on built-in Wi-Fi | `TBC` |
| ROS distribution | ROS Kinetic |
| Care-O-bot workspace | `~/josh_ws` |
| `ROBOT` profile | `cob4-24` |
| `ROBOT_ENV` profile | Not used; `4114c` is a map, not an environment profile |
| Dashboard launch command | `roslaunch cob_bringup dashboard.launch` |
| 4114c map | `~/4114c/map.yaml` |
| Navigation launch command | `roslaunch cob_navigation_global 2dnav_ros_dwa.launch robot:=$ROBOT map:=$COB24_MAP` |
| Emergency-stop controls and recovery owner | `TBC` |

The upstream Care-O-bot stack uses `ROBOT` to select the hardware profile and
can use `ROBOT_ENV` to select a navigation environment. The lab's `4114c`
directory contains only a map, so navigation receives its path explicitly
through `map:=$COB24_MAP`. The standard real-robot bringup entry point is
`cob_bringup robot.launch`. [Care-O-bot software overview](https://ros.fei.edu.br/roswiki/cob.html)

## Connect your laptop

Care-O-bot is connected to [Robotics Wi-Fi](index.md#robotics-wi-fi) and can
be accessed from `Robotics-2.4Ghz` or `Robotics-5Ghz`. For day-to-day work,
connect your laptop to **Care-O-bot's built-in Wi-Fi**: all the robot's
computers have static IP addresses on that network, making them easier to
access.

Ask the robot owner for the built-in Wi-Fi name, credentials, and static IP
addresses. The SSID and `b1` address still need to be recorded in the table
above. Configure your laptop's `cob24` SSH alias with the address of `b1` on
the network you are using; an address for one network may differ from the
address used on the other.

## Startup

### 1. Prepare the robot and area

1. Confirm that the robot and its control device are charged.
2. Disconnect the charger and make sure all covers and modules are secure.
3. Clear the test area, including the arm sweep and the mobile-base path.
4. Identify the physical emergency-stop controls and make sure the wireless
   stop device is available and charged, if fitted.
5. Check that the brake release is not engaged. Do not release an emergency
   stop merely to make a fault disappear.

### 2. Power on and wait

Use the labelled power control on the lab's Care-O-bot and wait for every
computer and hardware module to finish booting. A Care-O-bot installation can
take several minutes to start. Do not send ROS motion commands while the robot
is booting.

### 3. Start the verified lab bringup

Follow the [laptop connection instructions](#connect-your-laptop), preferably
using Care-O-bot's built-in Wi-Fi, then connect to `b1` using SSH. If you have
configured the `cob24` alias on your laptop, run:

```bash
ssh cob24
```

The remaining commands below run on the robot's computer, not on your laptop.

New interactive sessions in the configured robot account load the lab
environment automatically. To load it in an existing terminal, run:

```bash
source "$HOME/setup/cob24_env.sh"
```

This [environment script](assets/cob24_env.sh) only configures the terminal;
it does not start ROS nodes or move the robot. Check it loaded correctly:

```bash
echo "$ROBOT"
echo "$COB24_MAP"
```

Expected output is `cob4-24` and `/u/josh/4114c/map.yaml`.

Start hardware bringup only when the robot is physically ready:

```bash
# Starts hardware drivers and the base Care-O-bot stack.
roslaunch cob_bringup robot.launch
```

!!! warning
    `roslaunch cob_bringup robot.launch` can initialise live hardware. Run it
    only with a clear area, the correct profile, and a trained operator
    present. Do not use an example profile from the internet.

If the lab starts bringup inside `screen` or `tmux`, leave that session
running. This keeps the hardware drivers alive if the SSH connection closes.

### 4. Check before requesting movement

Run read-only checks first:

```bash
rosnode list
rostopic list
rosrun rqt_robot_monitor rqt_robot_monitor
```

Then open the lab dashboard and RViz:

```bash
roslaunch cob_bringup dashboard.launch
roslaunch cob_bringup rviz.launch
```

Check that the displayed posture, sensor data, and robot position agree with
the real robot. If navigation is enabled, set the initial pose only after you
have confirmed the correct map.

## Shutdown

1. Cancel navigation goals, teleoperation, arm actions, and any autonomous
   behaviour.
2. Return the robot to the agreed safe parking/base posture. Keep clear while
   the arm and torso move.
3. Stop launch files cleanly with `Ctrl+C`, then close related terminals or
   detach from the managed `screen`/`tmux` session as instructed by the robot
   owner.
4. Apply the robot's emergency-stop controls before power-off, if this is the
   established lab procedure.
5. Use the labelled Care-O-bot power control and wait for the robot computers
   to shut down before leaving it or connecting a charger.

Do not cut power while the robot is moving or while its computers are writing
data. The platform's Care-O-bot manual is the authority for the physical
controls on this specific robot revision. [Care-O-bot 4 user manual](https://mirrors.nju.edu.cn/ros-wiki/Robots%282f%29cob4%282f%29manual.html)

## Common modules

### Status and visualisation - safe first checks

| Module | Purpose | Safe first action |
|---|---|---|
| Robot monitor | Shows driver and hardware diagnostics | Open `rqt_robot_monitor` and resolve errors before motion |
| RViz | Shows transforms, sensor data, map, and planned paths | Verify the robot model and map position match reality |
| Dashboard | Sends approved initialise, posture, and task controls | Use only after the robot owner has shown the lab dashboard workflow |

### Navigation

Navigation requires the correct map, localisation, and a clear route. Start it
only after basic bringup is healthy and RViz shows a plausible robot pose. For
the lab's 4114c map, use:

```bash
roslaunch cob_navigation_global 2dnav_ros_dwa.launch \
  robot:="$ROBOT" map:="$COB24_MAP"
```

The standard Care-O-bot stack also provides separate SLAM modules. Do not run
SLAM against an existing map unless that is the experiment's purpose.

Before sending a goal:

1. Confirm the planned route has no people or obstacles.
2. Keep the emergency-stop control within reach.
3. Use a nearby observer for the first goal of a session.
4. Send a short, slow goal in an open area.

### Arm and gripper

The arm can sweep into areas that the base does not occupy. Start with the
robot's approved base posture, make sure its work surface is clear, and test
one low-speed motion at a time. Do not alter calibration files or run an
unfamiliar MoveIt/manipulation demo on the physical robot.

## Recovery after an emergency stop

Do not treat recovery as a button sequence. First remove the cause, cancel
any outstanding navigation or arm commands, and check whether an old goal
could re-run when power is restored. Then ask the trained robot owner to use
the lab's documented recovery procedure. Care-O-bot installations can retain
navigation goals across a stop, so blindly releasing a stop may cause renewed
motion.
