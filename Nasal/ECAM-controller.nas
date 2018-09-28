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
var wow = getprop("/gear/gear[1]/wow");
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
		if (getprop("/ECAM/msg/line" ~ line) == "" and me.active == 1 and me.msg != "") { # at empty line. Also checks if message is not blank to allow for some warnings with no displayed msg, eg stall
			setprop("/ECAM/msg/line" ~ line, me.msg);
			setprop("/ECAM/msg/linec" ~ line, me.colour);
		}
	},
	warnlight: func() {
		if ((me.light != "none" or me.light != "") and me.noRepeat == 0 and me.active == 1) { # only toggle light once per message, allows canceling 
			setprop("/ECAM/warnings/master-"~me.light~"-light", 1);
			me.noRepeat = 1;
		}
	},
	sound: func() {
		if (me.active and (me.aural != "none" or me.aural != "") and getprop("/sim/sound/warnings/"~me.aural) != 1) {
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
var pack1_fault = warning.new(msg: "AIR PACK 1 FAULT ", active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0),
var pack1_fault_subwarn_1 = warning.new(msg: "-PACK 1.............OFF ", active: 0, colour: "c", aural: "none", light: "none", noRepeat: 0),
var pack2_fault = warning.new(msg: "AIR PACK 2 FAULT ", active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0),
var pack2_fault_subwarn_1 = warning.new(msg: "-PACK 2.............OFF ", active: 0, colour: "c", aural: "none", light: "none", noRepeat: 0),
var park_brk_on = warning.new(msg: "PARK BRK ON", active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0)
]);

var memos = std.Vector.new([
var to_inhibit = memo.new(msg: "T.O. INHIBIT", active: 0, colour: "m"),
var ldg_inhibit = memo.new(msg: "LDG INHIBIT", active: 0, colour: "m"),
var spd_brk = memo.new(msg: "SPEED BRK", active: 0, colour: "g"),
var fob_3T = memo.new(msg: "FOB BELOW 3T", active: 0, colour: "g"),
var emer_gen = memo.new(msg: "EMER GEN", active: 0, colour: "g"),
var rat = memo.new(msg: "RAT OUT", active: 0, colour: "g"),
var gnd_splrs = memo.new(msg: "GND SPLRS ARMED", active: 0, colour: "g"),
var park_brk = memo.new(msg: "PARK BRK", active: 0, colour: "g"),
var refuelg = memo.new(msg: "REFUELG", active: 0, colour: "g"),
var ram_air = memo.new(msg: "RAM AIR ON", active: 0, colour: "g"),
var ptu = memo.new(msg: "HYD PTU", active: 0, colour: "g"),
var eng_aice = memo.new(msg: "ENG A.ICE", active: 0, colour: "g"),
var wing_aice = memo.new(msg: "WING A.ICE", active: 0, colour: "g"),
var fuelx = memo.new(msg: "FUEL X FEED", active: 0, colour: "g")
]);

var clearWarnings = std.Vector.new();

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
	if ((((getprop("/FMGC/status/phase") >= 1 and getprop("/FMGC/status/phase") <= 2) or (getprop("/FMGC/status/phase") >= 9 and getprop("/FMGC/status/phase") <= 10) and (wow and getprop("/engines/engine[0]/state") == 3)) or getprop("/FMGC/status/phase") == 6) and getprop("/systems/failures/pack1") == 1) {
		pack1_fault.active = 1;
	} else {
		pack1_fault.active = 0;
	}
	
	if (pack1_fault.active == 1 and getprop("/controls/pneumatic/switches/pack1") == 1) {
		pack1_fault_subwarn_1.active = 1;
	} else {
		pack1_fault_subwarn_1.active = 0;
	}
	
	if ((((getprop("/FMGC/status/phase") >= 1 and getprop("/FMGC/status/phase") <= 2) or (getprop("/FMGC/status/phase") >= 9 and getprop("/FMGC/status/phase") <= 10) and (wow and getprop("/engines/engine[1]/state") == 3)) or getprop("/FMGC/status/phase") == 6) and getprop("/systems/failures/pack2") == 1) {
		pack2_fault.active = 1;
	} else {
		pack2_fault.active = 0;
	}
	
	if (pack2_fault.active == 1 and getprop("/controls/pneumatic/switches/pack2") == 1) {
		pack2_fault_subwarn_1.active = 1;
	} else {
		pack2_fault_subwarn_1.active = 0;
	}
	
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
	if (getprop("/FMGC/status/phase") >= 3 and getprop("/FMGC/status/phase") <= 5) {
		to_inhibit.active = 1;
	} else {
		to_inhibit.active = 0;
	}
	
	if (getprop("/FMGC/status/phase") >= 7 and getprop("/FMGC/status/phase") <= 7) {
		ldg_inhibit.active = 1;
	} else {
		ldg_inhibit.active = 0;
	}
	
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
	
	if (getprop("/controls/pneumatic/switches/ram-air") == 1) {
		ram_air.active = 1;
	} else {
		ram_air.active = 0;
	}
	
	if (getprop("/controls/electrical/switches/emer-gen") == 1 and getprop("/controls/hydraulic/rat-deployed") == 1 and !wow) {
		emer_gen.active = 1;
	} else {
		emer_gen.active = 0;
	}
	
	if ((getprop("/FMGC/status/phase") >= 2 and getprop("/FMGC/status/phase") <= 7) and getprop("controls/flight/speedbrake") != 0) {
		spd_brk.active = 1;
	} else {
		spd_brk.active = 0;
	}
	
	if (getprop("/systems/thrust/state1") == "IDLE" and getprop("/systems/thrust/state2") == "IDLE" and getprop("/FMGC/status/phase") >= 6 and getprop("/FMGC/status/phase") <= 7) {
		spd_brk.colour = "g";
	} else if ((getprop("/FMGC/status/phase") >= 2 and getprop("/FMGC/status/phase") <= 5) or ((getprop("/systems/thrust/state1") != "IDLE" or getprop("/systems/thrust/state2") != "IDLE") and (getprop("/FMGC/status/phase") >= 6 and getprop("/FMGC/status/phase") <= 7))) {
		spd_brk.colour = "a";
	}
	
	if (getprop("services/fuel-truck/enable") == 1 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") {
		refuelg.active = 1;
	} else {
		refuelg.active = 0;
	}
	
	if (getprop("/consumables/fuel/total-fuel-lbs") < 6000 and getprop("/ECAM/left-msg") != "TO-MEMO" and getprop("/ECAM/left-msg") != "LDG-MEMO") { # assuming US short ton 2000lb
		fob_3T.active = 1;
	} else {
		fob_3T.active = 0;
	}
	
	if (getprop("/systems/fuel/x-feed") == 1 and getprop("controls/fuel/x-feed") == 1) {
		fuelx.active = 1;
	} else {
		fuelx.active = 0;
	}
	
	if (getprop("/FMGC/status/phase") >= 3 and getprop("/FMGC/status/phase") <= 5) {
		fuelx.colour = "a";
	} else {
		fuelx.colour = "g";
	}
	
	if (getprop("/controls/hydraulic/ptu") == 1 and ((getprop("/systems/hydraulic/yellow-psi") < 1450 and getprop("/systems/hydraulic/green-psi") > 1450 and getprop("/controls/hydraulic/elec-pump-yellow") == 0) or (getprop("/systems/hydraulic/yellow-psi") > 1450 and getprop("/systems/hydraulic/green-psi") < 1450))) {
		ptu.active = 1;
	} else {
		ptu.active = 0;
	}
	
	if (getprop("/controls/hydraulic/rat-deployed") == 1) {
		rat.active = 1;
	} else {
		rat.active = 0;
	}
	
	if (getprop("/FMGC/status/phase") >= 1 and getprop("/FMGC/status/phase") <= 2) {
		rat.colour = "a";
	} else {
		rat.colour = "g";
	}
	
	if (getprop("/controls/switches/leng") == 1 or getprop("/controls/switches/reng") == 1 or getprop("/systems/electrical/bus/dc1") == 0 or getprop("/systems/electrical/bus/dc2") == 0) {
		eng_aice.active = 1;
	} else {
		eng_aice.active = 0;
	}
	
	if (getprop("/controls/switches/wing") == 1) {
		eng_aice.active = 1;
	} else {
		eng_aice.active = 0;
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