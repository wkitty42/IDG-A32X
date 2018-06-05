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
var ewd = props.globals.initNode("/instrumentation/ewd");
var ewd_msg_three	= ewd.initNode("msg/priority_3"," ","STRING");
var ewd_msg_two		= ewd.initNode("msg/priority_2"," ","STRING");
var ewd_msg_one		= ewd.initNode("msg/priority_1"," ","STRING");
var ewd_msg_zero	= ewd.initNode("msg/priority_0"," ","STRING");
var ewd_msg_memo	= ewd.initNode("msg/memo"," ","STRING");
var msgs_priority_3 = [];
var msgs_priority_2 = [];
var msgs_priority_1 = [];
var msgs_priority_0 = [];
var msgs_memo = [];
var active_messages = [];
var num_lines = 6;
var msg = nil;
var spacer = nil;
var line = nil;

# messages logic and added to arrays

var messages_priority_3 = func {
	if (getprop("/controls/flight/flap-pos") > 2 and getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and getprop("/FMGC/status/phase") == 5) {
		append(msgs_priority_3,"L/G GEAR NOT DOWN");
		append(active_messages,"L/G GEAR NOT DOWN");
	}
}
var messages_priority_2 = func {}
var messages_priority_1 = func {}
var messages_priority_0 = func {}
var messages_memo = func {
	if (getprop("controls/flight/speedbrake-arm") == 1) {
			append(msgs_memo,"GND SPLRS ARMED");
			append(active_messages,"GND SPLRS ARMED");
		}
}

# messages sent to property tree

var update_ewd = func(msgs_priority_3,msgs_priority_2,msgs_priority_1,msgs_priority_0,msgs_memo) {
	msg = "";
	spacer = "";
	line = 0;
	for(var i=0; i<size(msgs_priority_3); i+=1)
	{
		msg = msg ~ msgs_priority_3[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	ewd_msg_three.setValue(msg);
	msg = spacer;
	for(var i=0; i<size(msgs_priority_2); i+=1)
	{
		msg = msg ~ msgs_priority_2[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	ewd_msg_two.setValue(msg);
	msg = spacer;
	for(var i=0; i<size(msgs_priority_1); i+=1)
	{
		msg = msg ~ msgs_priority_1[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	ewd_msg_one.setValue(msg);
	msg = spacer;
	for(var i=0; i<size(msgs_priority_0); i+=1)
	{
		msg = msg ~ msgs_priority_0[i] ~ "\n";
		spacer = spacer ~ "\n";
		line+=1;
	}
	ewd_msg_zero.setValue(msg);
	while (line+size(msgs_memo) < num_lines) {
		line+=1;
		spacer = spacer ~ "\n";
	}
	msg = spacer;
	for(var i=0; i<size(msgs_memo); i+=1)
	{
		msg = msg ~ msgs_memo[i] ~ "\n";
	}
	ewd_msg_memo.setValue(msg);
}

# Finally the controller

var ECAM_controller = {
	loop: func() {
		# cleans up arrays
		msgs_priority_3 = [];
		msgs_priority_2 = [];
		msgs_priority_1 = [];
		msgs_priority_0 = [];
		msgs_memo = [];
		active_messages = [];
		
		# check active messages
		# config_warnings();
		messages_priority_3();
		messages_priority_2();
		messages_priority_1();
		messages_priority_0();
		messages_memo();
		
		# update property tree with active messages
		update_ewd(msgs_priority_3,msgs_priority_2,msgs_priority_1,msgs_priority_0,msgs_memo);
		
		# write to ECAM
		foreach(var ewd_messages; active_messages) { 
			setprop("/ECAM/msg/line1", ewd_messages);
		}
	},
};
