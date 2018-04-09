# A3XX Electronic Centralised Aircraft Monitoring System
# Jonathan Redpath (legoboyvdlp)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

# Colors:
# 1 - Red, 2 - Amber, 3 - Cyan 4 - Green 5 - White

# Priority: 1 - LEVEL 3    2 - LEVEL 2    3 - LEVEL 1     4 - LEVEL 0     5 - MEMO
# LEVEL 3 has priority over all other warnings
# LEVEL 2 has priority over 1 and 0
# LEVEL 1 has priority over 0

# LEVEL 3 Messages Priority:
# Red visual warning, repetitive chime or sound
# 1 Stall
# 2 Over speed
# 3 Engine dual failure
# 4 Engine fire
# 5 APU fire
# 6 Takeoff configuration
# 7 Sidestick fault
# 8 Excessive cabin altitude
# 9 Engine oil lo pressure
# 10 L + R Elevator fault
# 11 Landing gear
# 12 Autopilot disconnection
# 13 Auto land
# 14 Smoke
# 15 Emergency configuration
# 16 Dual hydraulic failure

# LEVEL 2 Messages:
# Amber warning, single chime

# LEVEL 1 Messages:
# Amber warning, no chime

# LEVEL 0 Messages: 
# No visual warning or chime: ECAM blue, green, or white message

# TYPES: Independent, Primary and Secondary, Status, and MEMO

# Operation: FWC receives electrical boolean or numeric signals, from the systems, and outputs a message, audible warning, or visual alert

# Electrical Connection: FWC1 is controlled by AC ESS, FWC2 by AC BUS 2

# Sounds: reduce volume by 6DB is engines are off

# ARINC 429: 100kb/s (high speed)

# PHASE: /FMGC/status/phase

# DISPLAY: 1 - EWD 2 - MEMO 3 - STATUS

var message = {
	name: "",
	text: "",
	priority: 0,
	logic_prop: "",
	color: "",
	display: "",
	new: func(name,text,priority,logic_prop,color,display) {
		var l = {parents:[message]};
		
		l.name = name;
		l.text = text;
		l.priority = priority;
		l.logic_prop = logic_prop;
		l.color = color;
		l.display = display;
		
		return l;
	}
};

var messages = nil;


var ECAM_system = {
	init: func() {
		messages = [message.new(name: "RAM AIR P/B ON", text: "RAM AIR ON", priority: 5, logic_prop: "/controls/pneumatic/switches/ram-air", color: 4, display: 2), 
					message.new(name: "EMERGENCY GENERATOR", text: "EMER GEN", priority: 5, logic_prop: "/controls/electrical/switches/emer-gen", color: 4, display: 2),
					message.new(name: "GROUND SPOILERS ARMED", text: "GND SPLRS ARMED", priority: 5, logic_prop: "/controls/flight/speedbrake-arm", color: 4, display: 1)];
		active_messages = [];
		
	loop: func() {
		foreach(var message_controller; messages) { 
			if (getprop(message_controller.logic_prop) == 1){
				setprop("/ECAM/msg/line1", message_controller.text);
				if (getprop("/ECAM/left-msg") == "NONE") {
					setprop("/ECAM/left-msg","MSG")
				}
				if (message_controller.color == 1) {
					setprop("/ECAM/msg/line1c", "r");
				} else if (message_controller.color == 2) {
					setprop("/ECAM/msg/line1c", "a");
				} else if (message_controller.color == 3) {
					setprop("/ECAM/msg/line1c", "b");
				} else if (message_controller.color == 4) {
					setprop("/ECAM/msg/line1c", "g");
				} else if (message_controller.color == 5) {
					setprop("/ECAM/msg/line1c", "w");
				} else {
					setprop("/ECAM/msg/line1c", "w");
				}
			} else {
				setprop("/ECAM/msg/line1", "");
				
			}
		}
	},
};
