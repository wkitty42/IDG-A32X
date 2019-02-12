# A3XX Electronic Centralised Aircraft Monitoring System

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var num_lines = 6;
var msg = nil;
var spacer = nil;
var line = nil;
var right_line = nil;
var light = 0;
var flash = 0;
setprop("/ECAM/show-left-msg", 1);
setprop("/ECAM/show-right-msg", 1);
setprop("/ECAM/warnings/master-warning-light", 0);
setprop("/ECAM/warnings/master-warning-flash", 0);
setprop("/ECAM/warnings/master-caution-light", 0);

var lines = [props.globals.getNode("/ECAM/msg/line1", 1), props.globals.getNode("/ECAM/msg/line2", 1), props.globals.getNode("/ECAM/msg/line3", 1), props.globals.getNode("/ECAM/msg/line4", 1), props.globals.getNode("/ECAM/msg/line5", 1), props.globals.getNode("/ECAM/msg/line6", 1), props.globals.getNode("/ECAM/msg/line7", 1), props.globals.getNode("/ECAM/msg/line8", 1)];
var linesCol = [props.globals.getNode("/ECAM/msg/linec1", 1), props.globals.getNode("/ECAM/msg/linec2", 1), props.globals.getNode("/ECAM/msg/linec3", 1), props.globals.getNode("/ECAM/msg/linec4", 1), props.globals.getNode("/ECAM/msg/linec5", 1), props.globals.getNode("/ECAM/msg/linec6", 1), props.globals.getNode("/ECAM/msg/linec7", 1), props.globals.getNode("/ECAM/msg/linec8", 1)];
var leftOverflow  = props.globals.initNode("/ECAM/warnings/overflow-left", 0, "BOOL");
var rightOverflow = props.globals.initNode("/ECAM/warnings/overflow-right", 0, "BOOL");
var overflow = props.globals.initNode("/ECAM/warnings/overflow", 0, "BOOL");

var lights = [props.globals.initNode("/ECAM/warnings/master-warning-light", 0, "BOOL"), props.globals.initNode("/ECAM/warnings/master-caution-light", 0, "BOOL")]; 
var aural = [props.globals.initNode("/sim/sound/warnings/crc", 0, "BOOL"), props.globals.initNode("/sim/sound/warnings/chime", 0, "BOOL")];

var warning = {
	msg: "",
	active: 0,
	colour: "",
	aural: "",
	light: "",
	noRepeat: 0,
	clearFlag: 0,
	new: func(msg,active,colour,aural,light,noRepeat,clearFlag) {
		var t = {parents:[warning]};
		
		t.msg = msg;
		t.active = active;
		t.colour = colour;
		t.aural = aural;
		t.light = light;
		t.noRepeat = noRepeat;
		t.clearFlag = clearFlag;
		
		return t
	},
	write: func() {
		if (me.active == 0) {return;}
		lineIndex = 0;
		while (lines[lineIndex].getValue() != "" and lineIndex <= 7) {
			lineIndex = lineIndex + 1; # go to next line until empty line
		}
		
		if (lineIndex > 7) {
			leftOverflow.setBoolValue(1);
		} elsif (leftOverflow.getBoolValue() == 1) {
			leftOverflow.setBoolValue(0);
		}
		
		if (lines[lineIndex].getValue() == "" and me.msg != "" and lineIndex <= 7) { # at empty line. Also checks if message is not blank to allow for some warnings with no displayed msg, eg stall
			lines[lineIndex].setValue(me.msg);
			linesCol[lineIndex].setValue(me.colour);
		}
	},
	warnlight: func() {
		if (me.active == 0 or me.light >= 1) {return;}
		
		if (me.noRepeat == 0 and lights[me.light].getBoolValue() == 0) { # only toggle light once per message, allows canceling 
			lights[me.light].setBoolValue(1);
			me.noRepeat = 1;
		}
	},
	sound: func() {
		if (me.active == 0 or me.aural >= 1) {return;}
		if (aural[me.aural].getBoolValue() != 1) {
			aural[me.aural].setBoolValue(1);
		}
		# have to cancel it anyway, I think it does not go out even if failure is removed
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
		if (me.active == 1) {
			right_line = 1;
			while (getprop("/ECAM/rightmsg/line" ~ right_line) != "" and right_line <= 8) {
				right_line = right_line + 1; # go to next line until empty line
			} 
			
			if (right_line > 8) {
				setprop("/ECAM/warnings/overflow-right", 1);
			} elsif (getprop("/ECAM/warnings/overflow-right") == 1) {
				setprop("/ECAM/warnings/overflow-right", 0);
			}
			
			if (getprop("/ECAM/rightmsg/line" ~ right_line) == "" and right_line <= 8) { # at empty line
				setprop("/ECAM/rightmsg/line" ~ right_line, me.msg);
				setprop("/ECAM/rightmsg/linec" ~ right_line, me.colour);
			}
		}
	},
};

var status = {
	msg: "",
	active: 0,
	colour: "",
	new: func(msg,active,colour) {
		var t = {parents:[status]};
		
		t.msg = msg;
		t.active = active;
		t.colour = colour;
		
		return t
	},
	write: func() {
		if (me.active == 1) {
			status_line = 1;
			while (getprop("/ECAM/status/line" ~ status_line) != "" and status_line <= 8) {
				status_line = status_line + 1; # go to next line until empty line
			} 
			
			if (getprop("/ECAM/status/line" ~ status_line) == "" and status_line <= 8) { # at empty line
				setprop("/ECAM/status/line" ~ status_line, me.msg);
				setprop("/ECAM/status/linec" ~ status_line, me.colour);
			}
		}
	},
};

var ECAM_controller = {
	init: func() {
		ECAMloopTimer.start();
		me.reset();
	},
	loop: func() {
		# check active messages
		messages_priority_3();
		messages_priority_2();
		messages_priority_1();
		messages_priority_0();
		messages_memo();
		messages_right_memo();
		
		# clear display momentarily
		
		
		for(var n = 1; n <= 8; n += 1) {
			setprop("/ECAM/msg/line" ~ n, "");
		}
		
		for(var n = 1; n <= 8; n += 1) {
			setprop("/ECAM/rightmsg/line" ~ n, "");
		}
		
		# write to ECAM
		
		foreach (var w; warnings.vector) {
			w.write();
			w.warnlight();
			w.sound();
		}
		
		if (getprop("/ECAM/msg/line1") == "") { # disable left memos if a warning exists. Warnings are processed first, so this stops leftmemos if line1 is not empty
			foreach (var l; leftmemos.vector) {
				l.write();
			}
		}
		
		foreach (var sL; specialLines.vector) {
			sL.write();
		}
		
		foreach (var sF; secondaryFailures.vector) {
			sF.write();
		}
		
		foreach (var m; memos.vector) {
			m.write();
		}
		
		if (getprop("/ECAM/warnings/overflow-left") == 1 or getprop("/ECAM/warnings/overflow-right") == 1) {
			setprop("/ECAM/warnings/overflow", 1);
		} elsif (getprop("/ECAM/warnings/overflow-left") == 0 and getprop("/ECAM/warnings/overflow-right") == 0) {
			setprop("/ECAM/warnings/overflow", 0);
		}
	},
	reset: func() {
		foreach (var w; warnings.vector) {
			if (w.active == 1) {
				w.active = 0;
			}
		}
		
		foreach (var l; leftmemos.vector) {
			if (l.active == 1) {
				l.active = 0;
			}
		}
		
		foreach (var sL; specialLines.vector) {
			if (sL.active == 1) {
				sL.active = 0;
			}
		}
		
		foreach (var sF; secondaryFailures.vector) {
			if (sF.active == 1) {
				sF.active = 0;
			}
		}
		
		foreach (var m; memos.vector) {
			if (m.active == 1) {
				m.active = 0;
			}
		}
	},
	clear: func() {
		foreach (var w; warnings.vector) {
			if (w.active == 1) {
				w.active = 0;   # todo: need to hit CLR to clear condition, not automatic
				w.noRepeat = 0; # should warning only clear if condition is not true?
				w.clearFlag = 1;
				break;
			}
		}
	},
	recall: func() {
		foreach (var w; warnings.vector) {
			if (w.clearFlag == 1) {
				w.active = 1;
				w.noRepeat = 1;
				w.clearFlag = 0;
				break;
			}
		}
	},
};

setlistener("/systems/electrical/bus/dc-ess", func {
	if (getprop("/systems/electrical/bus/dc-ess") < 25) {
		ECAM_controller.reset();
	}
}, 0, 0);

var ECAMloopTimer = maketimer(0.2, func {
	ECAM_controller.loop();
});

# Flash Master Warning Light
var warnTimer = maketimer(0.25, func {
	flash = getprop("/ECAM/warnings/master-warning-flash");
	light = getprop("/ECAM/warnings/master-warning-light");
	if (!light) {
		warnTimer.stop();
		setprop("/ECAM/warnings/master-warning-flash", 0);
	} else if (flash != 1) {
		setprop("/ECAM/warnings/master-warning-flash", 1);
	} else {
		setprop("/ECAM/warnings/master-warning-flash", 0);
	}
});

setlistener("/ECAM/warnings/master-warning-light", func {
	light = getprop("/ECAM/warnings/master-warning-light");
	if (light == 1) {
		setprop("/ECAM/warnings/master-warning-flash", 0);
		warnTimer.start();
	} else {
		warnTimer.stop();
		setprop("/ECAM/warnings/master-warning-flash", 0);
	}
}, 0, 0);
