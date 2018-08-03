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

# commented lines of logic are waiting for proper FMGC warning phases
var num_lines = 6;
var msg = nil;
var spacer = nil;
var line = nil;
var right_line = nil;
setprop("/ECAM/warnings/master-warning-light", 0);
setprop("/ECAM/warnings/master-caution-light", 0);

var warning = {
	msg: "",
	active: 0,
	colour: "",
	aural: "",
	light: "",
	noRepeat: 0,
	new: func(msg,active,colour,aural,light,noRepeat) {
		
		var t = {parents:[warning]};
		
		t.msg = msg;
		t.active = active;
		t.colour = colour;
		t.aural = aural;
		t.light = light;
		t.noRepeat = noRepeat;
		
		return t
	
	},
	write: func() {
		var line = 1;
		while (getprop("/ECAM/msg/line" ~ line) != "") {
			line = line + 1; # go to next line until empty line
		}
		
		# if (getprop("/ECAM/msg/line" ~ line) != me.msg)
		if (getprop("/ECAM/msg/line" ~ line) == "" and me.active == 1) { # at empty line
			setprop("/ECAM/msg/line" ~ line, me.msg);
			setprop("/ECAM/msg/linec" ~ line, me.colour);
		}
	},
	warnlight: func() {
		if (me.light != "none" and me.noRepeat == 0 and me.active == 1) { # only toggle light once per message, allows canceling 
			setprop("/ECAM/warnings/master-"~me.light~"-light", 1);
			me.noRepeat = 1;
		}
	},
	sound: func() {
		if (me.active and me.aural != "none" and getprop("/sim/sound/warnings/"~me.aural) != 1) {
			setprop("/sim/sound/warnings/"~me.aural, 1);
		} else if (!me.active or me.aural == "none") {
			if (getprop("/sim/sound/warnings/"~me.aural) == 1) {
				setprop("/sim/sound/warnings/"~me.aural, 0);
			}
		}
	},
};

var memo = {
	msg: "",
	active: 0,
	colour: "",
	new: func(msg,active,colour) {
		
		var t = {parents:[memo]};
		
		t.msg = msg;
		t.active = active;
		t.colour = colour;
		
		return t
	
	},
	write: func() {
		var right_line = 1;
		while (getprop("/ECAM/rightmsg/line" ~ right_line) != "") {
			right_line = right_line + 1; # go to next line until empty line
		} 
		
		if (getprop("/ECAM/rightmsg/line" ~ right_line) == "" and me.active == 1) { # at empty line
			setprop("/ECAM/rightmsg/line" ~ right_line, me.msg);
			setprop("/ECAM/rightmsg/linec" ~ right_line, me.colour);
		}
	},
};
# messages logic and added to arrays

var warnings = std.Vector.new([
var lg_not_dn = warning.new(msg: "L/G GEAR NOT DOWN", active: 0, colour: "r", aural: "crc", light: "warning", noRepeat: 0),
var park_brk_on = warning.new(msg: "PARK BRK ON", active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0)
]);

var memos = std.Vector.new([
var gnd_splrs = memo.new(msg: "GND SPLRS ARMED", active: 0, colour: "g"),
var park_brk = memo.new(msg: "PARK BRK", active: 0, colour: "g")
]);


var messages_priority_3 = func {
	if (getprop("/controls/flight/flap-pos") > 2 and getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and getprop("/FMGC/status/phase") == 5) {
	# if ((getprop("/controls/flight/flap-pos") > 2 and getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and (getprop("/FMGC/status/phase") != 3 and getprop("/FMGC/status/phase") != 4 and getprop("/FMGC/status/phase") != 5)) or ((getprop("/engines/engine[0]/n1-actual") < 75.0 and getprop("/engines/engine[1]/n1-actual") < 75.0) and getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and (getprop("/FMGC/status/phase") != 3 and getprop("/FMGC/status/phase") != 4 and getprop("/FMGC/status/phase") != 5 and getprop("/FMGC/status/phase") != 6)) or (((getprop("/engines/engine[0]/n1-actual") < 77.0 and getprop("/controls/engines/engine[1]/cutoff-switch") == 0) or (getprop("/engines/engine[1]/n1-actual") < 77.0 and getprop("/controls/engines/engine[0]/cutoff-switch") == 0) and getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and (getprop("/FMGC/status/phase") != 3 and getprop("/FMGC/status/phase") != 4 and getprop("/FMGC/status/phase") != 5 and getprop("/FMGC/status/phase") != 6))) {
	lg_not_dn.active = 1;
	} else {
		lg_not_dn.active = 0;
		lg_not_dn.noRepeat = 0;
	}
}
var messages_priority_2 = func {
	# if (getprop("/controls/gear/brake-parking") and (getprop("/FMGC/status/phase") >= 6 and getprop("/FMGC/status/phase") <= 7)) {
	if (getprop("/controls/gear/brake-parking") and (getprop("/FMGC/status/phase") >= 2 and getprop("/FMGC/status/phase") <= 5)) {
		park_brk_on.active = 1;
	} else {
		park_brk_on.active = 0;
		park_brk_on.noRepeat = 0;
	}
}
var messages_priority_1 = func {}
var messages_priority_0 = func {}
var messages_memo = func {}
var messages_right_memo = func {
	if (getprop("controls/flight/speedbrake-arm") == 1) {
		gnd_splrs.active = 1;
	} else {
		gnd_splrs.active = 0;
	}
	
	#if (getprop("/controls/gear/brake-parking") == 1 and getprop("/FMGC/status/phase") != 3) {
	if (getprop("/controls/gear/brake-parking") == 1) {
		park_brk.active = 1;
	} else {
		park_brk.active = 0;
	}
	if (getprop("/FMGC/status/phase") >= 4 and getprop("/FMGC/status/phase") <= 8) {
		park_brk.colour = "a";
	} else {
		park_brk.colour = "g";
	}
}

# Finally the controller

var ECAM_controller = {
	loop: func() {
		
		# check active messages
		# config_warnings();
		messages_priority_3();
		messages_priority_2();
		messages_priority_1();
		messages_priority_0();
		messages_memo();
		messages_right_memo();
		
		# clear display momentarily
		
		
		if (warnings.size() > 0) {
			for(var n=1; n<8; n+=1) {
				setprop("/ECAM/msg/line" ~ n, "");
			}
		}
		
		if (memos.size() > 0) {
			for(var n=1; n<8; n+=1) {
				setprop("/ECAM/rightmsg/line" ~ n, "");
			}
		}
		
		# write to ECAM
		
		foreach (var i; warnings.vector) {
			i.write();
			i.warnlight();
			i.sound();
		}
		
		foreach (var m; memos.vector) {
			m.write();
		}
	},
};
