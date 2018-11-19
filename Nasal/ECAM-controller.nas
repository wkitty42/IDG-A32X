# A3XX Electronic Centralised Aircraft Monitoring System
# Jonathan Redpath (legoboyvdlp)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var num_lines = 6;
var msg = nil;
var spacer = nil;
var line = nil;
var right_line = nil;
var wow = getprop("/gear/gear[1]/wow");
setprop("/ECAM/show-left-msg", 1);
setprop("/ECAM/show-right-msg", 1);
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
	var pack1_fault_subwarn_1 = warning.new(msg: "-PACK 1.............OFF ", active: 0, colour: "b", aural: "none", light: "none", noRepeat: 0),
	var pack2_fault = warning.new(msg: "AIR PACK 2 FAULT ", active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0),
	var pack2_fault_subwarn_1 = warning.new(msg: "-PACK 2.............OFF ", active: 0, colour: "b", aural: "none", light: "none", noRepeat: 0),
	var park_brk_on = warning.new(msg: "PARK BRK ON", active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0)
]);

var activeWarnings = std.Vector.new();

var leftmemos = std.Vector.new([
	var company_alert = warning.new(msg: "COMPANY ALERT", active: 0, colour: "g", aural: "buzzer", light: "none", noRepeat: 0), # Not yet implemented, buzzer sound
	var refuelg = warning.new(msg: "REFUELG", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var irs_in_align = warning.new(msg: "IRS IN ALIGN", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0), # Not yet implemented
	var gnd_splrs = warning.new(msg: "GND SPLRS ARMED", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var seatbelts = warning.new(msg: "SEAT BELTS", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var nosmoke = warning.new(msg: "NO SMOKING", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var strobe_lt_off = warning.new(msg: "STROBE LT OFF", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var outr_tk_fuel_xfrd = warning.new(msg: "OUTR TK FUEL XFRD", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0), # Not yet implemented
	var fob_3T = warning.new(msg: "FOB BELOW 3T", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var gpws_flap_mode_off = warning.new(msg: "GPWS FLAP MODE OFF", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0),
	var atc_datalink_stby = warning.new(msg: "ATC DATALINK STBY", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0), # Not yet implemented
	var company_datalink_stby = warning.new(msg: "COMPANY DATALINK STBY", active: 0, colour: "g", aural: "none", light: "none", noRepeat: 0) # Not yet implemented
]);

var memos = std.Vector.new([
	var to_inhibit = memo.new(msg: "T.O. INHIBIT", active: 0, colour: "m"),
	var ldg_inhibit = memo.new(msg: "LDG INHIBIT", active: 0, colour: "m"),
	var land_asap_r = memo.new(msg: "LAND ASAP", active: 0, colour: "r"),
	var land_asap_a = memo.new(msg: "LAND ASAP", active: 0, colour: "a"),
	var ap_off = memo.new(msg: "AP OFF", active: 0, colour: "r"),
	var athr_off = memo.new(msg: "A/THR OFF", active: 0, colour: "a"),
	var spd_brk = memo.new(msg: "SPEED BRK", active: 0, colour: "g"),
	var park_brk = memo.new(msg: "PARK BRK", active: 0, colour: "g"),
	var ptu = memo.new(msg: "HYD PTU", active: 0, colour: "g"),
	var rat = memo.new(msg: "RAT OUT", active: 0, colour: "g"),
	var emer_gen = memo.new(msg: "EMER GEN", active: 0, colour: "g"),
	var ram_air = memo.new(msg: "RAM AIR ON", active: 0, colour: "g"),
	var nw_strg_disc = memo.new(msg: "NW STRG DISC", active: 0, colour: "g"),
	var ignition = memo.new(msg: "IGNITION", active: 0, colour: "g"),
	var cabin_ready = memo.new(msg: "CABIN READY", active: 0, colour: "g"), # Not yet implemented
	var pred_ws_off = memo.new(msg: "PRED W/S OFF", active: 0, colour: "g"), # Not yet implemented
	var terr_stby = memo.new(msg: "TERR STBY", active: 0, colour: "g"), # Not yet implemented
	var tcas_stby = memo.new(msg: "TCAS STBY", active: 0, colour: "g"), # Not yet implemented
	var acars_call = memo.new(msg: "ACARS CALL", active: 0, colour: "g"), # Not yet implemented
	var company_call = memo.new(msg: "COMPANY CALL", active: 0, colour: "g"), # Not yet implemented
	var satcom_alert = memo.new(msg: "SATCOM ALERT", active: 0, colour: "g"), # Not yet implemented
	var acars_msg = memo.new(msg: "ACARS MSG", active: 0, colour: "g"), # Not yet implemented
	var company_msg = memo.new(msg: "COMPANY MSG", active: 0, colour: "g"), # Not yet implemented
	var eng_aice = memo.new(msg: "ENG A.ICE", active: 0, colour: "g"),
	var wing_aice = memo.new(msg: "WING A.ICE", active: 0, colour: "g"),
	var ice_not_det = memo.new(msg: "ICE NOT DET", active: 0, colour: "g"), # Not yet implemented
	var hi_alt = memo.new(msg: "HI ALT", active: 0, colour: "g"), # Not yet implemented
	var apu_avail = memo.new(msg: "APU AVAIL", active: 0, colour: "g"),
	var apu_bleed = memo.new(msg: "APU BLEED", active: 0, colour: "g"), # Not yet implemented
	var ldg_lt = memo.new(msg: "LDG LT", active: 0, colour: "g"),
	var brk_fan = memo.new(msg: "BRK FAN", active: 0, colour: "g"), # Not yet implemented
	var audio3_xfrd = memo.new(msg: "AUDIO 3 XFRD", active: 0, colour: "g"), # Not yet implemented
	var switchg_pnl = memo.new(msg: "SWITCHG PNL", active: 0, colour: "g"), # Not yet implemented
	var gpws_flap3 = memo.new(msg: "GPWS FLAP 3", active: 0, colour: "g"), 
	var hf_data_ovrd = memo.new(msg: "HF DATA OVRD", active: 0, colour: "g"), # Not yet implemented
	var hf_voice = memo.new(msg: "HF VOICE", active: 0, colour: "g"), # Not yet implemented
	var acars_stby = memo.new(msg: "ACARS STBY", active: 0, colour: "g"), # Not yet implemented
	var vhf3_voice = memo.new(msg: "VHF3 VOICE", active: 0, colour: "g"),
	var auto_brk_lo = memo.new(msg: "AUTO BRK LO", active: 0, colour: "g"),
	var auto_brk_med = memo.new(msg: "AUTO BRK MED", active: 0, colour: "g"),
	var auto_brk_max = memo.new(msg: "AUTO BRK MAX", active: 0, colour: "g"),
	var auto_brk_off = memo.new(msg: "AUTO BRK OFF", active: 0, colour: "g"), # Not yet implemented
	var man_ldg_elev = memo.new(msg: "MAN LDG ELEV", active: 0, colour: "g"), # Not yet implemented
	var ctr_tk_feedg = memo.new(msg: "CTR TK FEEDG", active: 0, colour: "g"),
	var fuelx = memo.new(msg: "FUEL X FEED", active: 0, colour: "g")
]);

var clearWarnings = std.Vector.new();

var ECAM_controller = {
	loop: func() {
		# check active messages
		# config_warnings();
		# messages_priority_3();
		# messages_priority_2();
		# messages_priority_1();
		# messages_priority_0();
		messages_memo();
		messages_right_memo();
		
		# clear display momentarily
		
		
		for(var n = 1; n < 8; n += 1) {
			setprop("/ECAM/msg/line" ~ n, "");
		}
		
		for(var n = 1; n < 8; n += 1) {
			setprop("/ECAM/rightmsg/line" ~ n, "");
		}
		
		# write to ECAM
		
		# foreach (var w; warnings.vector) {
		#	w.write();
		#	w.warnlight();
		#	w.sound();
		# }
		
		foreach (var l; leftmemos.vector) {
			l.write();
		}
		
		foreach (var m; memos.vector) {
			m.write();
		}
	},
};
