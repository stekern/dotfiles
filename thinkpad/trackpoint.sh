#! /bin/bash
#
# trackpoint.sh
# Copyright (C) 2018 Erlend Ekern <dev@ekern.me>
#
# Distributed under terms of the MIT license.
#


# Enable natural scrolling using trackpoint
xinput --set-prop "TPPS/2 IBM TrackPoint" "libinput Natural Scrolling Enabled" 1

# Lower acceleration of trackpoint
xinput --set-prop "TPPS/2 IBM TrackPoint" "libinput Accel Speed" -0.4

# Change acceleration profile
# You'll need to up the acceleration if using this profile
#xinput --set-prop "TPPS/2 IBM TrackPoint" "libinput Accel Profile Enabled" 0, 1
