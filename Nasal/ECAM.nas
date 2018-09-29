# A3XX ECAM Messages
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

setprop("/ECAM/left-msg", "NONE");
setprop("/position/gear-agl-ft", 0);
# w = White, b = Blue, g = Green, a = Amber, r = Red

var ECAM = {
	init: func() {
		setprop("/ECAM/engine-start-time", 0);
		setprop("/ECAM/engine-start-time-switch", 0);
		setprop("/ECAM/to-memo-enable", 1);
		setprop("/ECAM/to-config", 0);
		setprop("/ECAM/ldg-memo-enable", 0);
		setprop("/ECAM/Lower/page", "door");
		setprop("/ECAM/Lower/man-select", 0);
		setprop("/ECAM/Lower/fault-select", 0);
		setprop("/ECAM/Lower/apu-timer", 0);
		setprop("/ECAM/Lower/eng-timer", 0);
		setprop("/ECAM/Lower/fctl-timer", 0);
		setprop("/ECAM/Lower/light/apu", 0);
		setprop("/ECAM/Lower/light/bleed", 0);
		setprop("/ECAM/Lower/light/cond", 0);
		setprop("/ECAM/Lower/light/door", 0);
		setprop("/ECAM/Lower/light/elec", 0);
		setprop("/ECAM/Lower/light/eng", 0);
		setprop("/ECAM/Lower/light/fctl", 0);
		setprop("/ECAM/Lower/light/fuel", 0);
		setprop("/ECAM/Lower/light/hyd", 0);
		setprop("/ECAM/Lower/light/press", 0);
		setprop("/ECAM/Lower/light/sts", 0);
		setprop("/ECAM/Lower/light/wheel", 0);
		var stateL = getprop("/engines/engine[0]/state");
		var stateR = getprop("/engines/engine[1]/state");
		var thrustL = getprop("/systems/thrust/state1");
		var thrustR = getprop("/systems/thrust/state2");
		var elec = getprop("/systems/electrical/on");
		var speed = getprop("/velocities/airspeed-kt");
		var wow = getprop("/gear/gear[0]/wow");
		var altitude = getprop("/position/gear-agl-ft");
		LowerECAM.reset();
	},
	MSGclr: func() {
		setprop("/ECAM/ecam-checklist-active", 0);
		setprop("/ECAM/left-msg", "NONE");
		setprop("/ECAM/msg/line1", "");
		setprop("/ECAM/msg/line2", "");
		setprop("/ECAM/msg/line3", "");
		setprop("/ECAM/msg/line4", "");
		setprop("/ECAM/msg/line5", "");
		setprop("/ECAM/msg/line6", "");
		setprop("/ECAM/msg/line7", "");
		setprop("/ECAM/msg/line8", "");
		setprop("/ECAM/msg/linec1", "w");
		setprop("/ECAM/msg/linec2", "w");
		setprop("/ECAM/msg/linec3", "w");
		setprop("/ECAM/msg/linec4", "w");
		setprop("/ECAM/msg/linec5", "w");
		setprop("/ECAM/msg/linec6", "w");
		setprop("/ECAM/msg/linec7", "w");
		setprop("/ECAM/msg/linec8", "w");
		setprop("/ECAM/rightmsg/line1", "");
		setprop("/ECAM/rightmsg/line2", "");
		setprop("/ECAM/rightmsg/line3", "");
		setprop("/ECAM/rightmsg/line4", "");
		setprop("/ECAM/rightmsg/line5", "");
		setprop("/ECAM/rightmsg/line6", "");
		setprop("/ECAM/rightmsg/line7", "");
		setprop("/ECAM/rightmsg/line8", "");
		setprop("/ECAM/rightmsg/linec1", "w");
		setprop("/ECAM/rightmsg/linec2", "w");
		setprop("/ECAM/rightmsg/linec3", "w");
		setprop("/ECAM/rightmsg/linec4", "w");
		setprop("/ECAM/rightmsg/linec5", "w");
		setprop("/ECAM/rightmsg/linec6", "w");
		setprop("/ECAM/rightmsg/linec7", "w");
		setprop("/ECAM/rightmsg/linec8", "w");
	},
	loop: func() {
		stateL = getprop("/engines/engine[0]/state");
		stateR = getprop("/engines/engine[1]/state");
		thrustL = getprop("/systems/thrust/state1");
		thrustR = getprop("/systems/thrust/state2");
		elec = getprop("/systems/electrical/on");
		speed = getprop("/velocities/airspeed-kt");
		wow = getprop("/gear/gear[0]/wow");
		
		if (stateL == 3 and stateR == 3 and wow == 1) {
			if (getprop("/ECAM/engine-start-time-switch") != 1) {
				setprop("/ECAM/engine-start-time", getprop("/sim/time/elapsed-sec"));
				setprop("/ECAM/engine-start-time-switch", 1);
			}
		} else if (wow == 1) {
			if (getprop("/ECAM/engine-start-time-switch") != 0) {
				setprop("/ECAM/engine-start-time-switch", 0);
			}
		}
		
		if (wow == 0) {
			setprop("/ECAM/to-memo-enable", 0);
		} else if ((stateL != 3 or stateR != 3) and wow == 1) {
			setprop("/ECAM/to-memo-enable", 1);
		}
		
		if (getprop("/position/gear-agl-ft") <= 2000 and (getprop("/FMGC/status/phase") == 3 or getprop("/FMGC/status/phase") == 4 or getprop("/FMGC/status/phase") == 5) and wow == 0) {
			setprop("/ECAM/ldg-memo-enable", 1);
		} else if (getprop("/ECAM/left-msg") == "LDG-MEMO" and getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") <= 80 and wow == 1) {
			setprop("/ECAM/ldg-memo-enable", 0);
		} else if (getprop("/ECAM/left-msg") != "LDG-MEMO") {
			setprop("/ECAM/ldg-memo-enable", 0);
		}
		
		if (ecam.warnings.size() > 0) {
			setprop("/ECAM/left-msg", "MSG");
		} else if (getprop("/FMGC/status/phase") == 0 and stateL == 3 and stateR == 3 and getprop("/ECAM/engine-start-time") + 120 < getprop("/sim/time/elapsed-sec") and getprop("/ECAM/to-memo-enable") == 1 and wow == 1) {
			setprop("/ECAM/left-msg", "TO-MEMO");
		} else if (getprop("/ECAM/ldg-memo-enable") == 1) {
			setprop("/ECAM/left-msg", "LDG-MEMO");
		} else {
			setprop("/ECAM/left-msg", "NONE");
		}
		
		if (ecam.memos.size() > 0) {
			setprop("/ECAM/right-msg", "MSG");
		} else {
			setprop("/ECAM/right-msg", "NONE");
		}
		
		if (getprop("/controls/autobrake/mode") == 3 and getprop("/controls/switches/no-smoking-sign") == 1 and getprop("/controls/switches/seatbelt-sign") == 1 and getprop("/controls/flight/speedbrake-arm") == 1 and getprop("/controls/flight/flap-pos") > 0 
		and getprop("/controls/flight/flap-pos") < 5) {
			# Do nothing
		} else {
			setprop("/ECAM/to-config", 0);
		}
		
		LowerECAM.loop();
	},
	toConfig: func() {
		stateL = getprop("/engines/engine[0]/state");
		stateR = getprop("/engines/engine[1]/state");
		wow = getprop("/gear/gear[0]/wow");
		
		if (wow == 1 and stateL == 3 and stateR == 3 and getprop("/ECAM/left-msg") != "TO-MEMO") {
			setprop("/ECAM/to-memo-enable", 1);
			setprop("/ECAM/engine-start-time", getprop("/ECAM/engine-start-time") - 120);
		}
		
		if (getprop("/controls/autobrake/mode") == 3 and getprop("/controls/switches/no-smoking-sign") == 1 and getprop("/controls/switches/seatbelt-sign") == 1 and getprop("/controls/flight/speedbrake-arm") == 1 and getprop("/controls/flight/flap-pos") > 0 
		and getprop("/controls/flight/flap-pos") < 5) {
			setprop("/ECAM/to-config", 1);
		}
	},
};

ECAM.MSGclr();

var LowerECAM = {
	button: func(b) {
		var man_sel = getprop("/ECAM/Lower/man-select");

		if(!getprop("/ECAM/lower/fault-select")) {
			if(!man_sel) {
				setprop("/ECAM/Lower/man-select", 1);
				setprop("/ECAM/Lower/page", b);
				setprop("/ECAM/Lower/light/" ~ b, 1);
			} else {
				if(b == getprop("/ECAM/Lower/page")) {
					setprop("/ECAM/Lower/man-select", 0);
					LowerECAM.loop();
					setprop("/ECAM/Lower/light/" ~ b, 0);
				} else {
					setprop("/ECAM/Lower/light/" ~ getprop("/ECAM/Lower/page"), 0);
					setprop("/ECAM/Lower/page", b);
					setprop("/ECAM/Lower/light/" ~ b, 1);
				}
			}
		}
	},
	loop: func() {
		var man_sel = getprop("/ECAM/Lower/man-select");
		var fault_sel = getprop("/ECAM/Lower/fault-select");

		if(!man_sel) {

			if(!fault_sel) {
				var apu_timer = getprop("/ECAM/Lower/apu-timer");
				var apu_n = getprop("/systems/apu/rpm");
				var apu_master = getprop("/controls/APU/master");

				var eng_timer = getprop("/ECAM/Lower/eng-timer");
				var eng_to = getprop("/ECAM/Lower/eng-to");
				var eng1_state = getprop("/engines/engine[0]/state");
				var eng2_state = getprop("/engines/engine[1]/state");
				var eng_mode = getprop("/controls/engines/engine-start-switch");

				var flaps = getprop("/controls/flight/flap-lever");
				var agl = getprop("/position/gear-agl-ft");

				var phase = getprop("/FMGC/status/phase");
				var gear0 = getprop("/gear/gear[0]/wow");
				var n1_left = getprop("/engines/engine[0]/n1-actual");
				var n1_right = getprop("/engines/engine[1]/n1-actual");
				var state1 = getprop("/systems/thrust/state1");
				var state2 = getprop("/systems/thrust/state2");
				var flx = getprop("/systems/thrust/lim-flex");
				var thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
				var thr2 = getprop("/controls/engines/engine[1]/throttle-pos");

				var eng_out = 0;
				if ((getprop("/engines/engine[0]/state") == 3 and getprop("/engines/engine[1]/state") != 3) or (getprop("/engines/engine[0]/state") != 3 and getprop("/engines/engine[1]/state") == 3)) {
					eng_out = 1;
				}

				var to_thr = 0;
				if (n1_left >= 70 and state1 == "TOGA" or (flx == 1 and state1 == "MCT" and eng_out == 0)
					or (flx == 1 and (state1 == "MAN THR" and thr1 >= 0.83 and eng_out == 0))
					or n1_right >= 70 and state2 == "TOGA" or (flx == 1 and state2 == "MCT" and eng_out == 0)
					or (flx == 1 and (state2 == "MAN THR" and thr2 >= 0.83 and eng_out == 0))) {
					to_thr = 1;
				}

				#TODO auto select page for F/CTL
				if ( eng_mode == 0
					or eng1_state == 1
					or eng1_state == 2
					or eng2_state == 1
					or eng2_state == 2
					or (to_thr == 1 and agl < 1500)
					or eng_to == 1
					or eng_timer > 0) {

					if (eng_timer == 0) {
						setprop("/ECAM/Lower/eng-timer", 1);
					}

					if (eng_mode == 1 and to_thr == 0) {
						setprop("/ECAM/Lower/eng-timer", 0);
					}

					if (to_thr == 1 and agl <= 1500) {
						setprop("/ECAM/Lower/eng-to", 1);
					}

					if (eng_to == 1 and flaps == 0 and to_thr == 0 and agl >= 1500) {
						setprop("/ECAM/Lower/eng-to", 0);
					}

					if ((eng1_state == 0 or eng1_state == 3) and (eng2_state == 0 or eng2_state == 3) and gear0 == 1 and to_thr == 0) {
						settimer(func() { setprop("/ECAM/Lower/eng-timer", 0);}, 10);
					}

					if (eng_to == 1 and agl >= 1500) {
						settimer(func() { setprop("/ECAM/Lower/eng-to", 0);}, 60);
					}

					setprop("/ECAM/Lower/page", "eng");

				} else if ((apu_master == 1 and apu_n < 95) or apu_timer > 0) {
					# apu-timer states:
					#	0 -> no apu start
					#	1 -> apu starting/started, will be set back to 0 by timer
					if (apu_timer == 0) {
						setprop("/ECAM/Lower/apu-timer", 1);
					}

					if (apu_master == 0) {
						setprop("/ECAM/Lower/apu-timer", 0);
					}

					if (apu_n >= 95) {
						settimer(func() { setprop("/ECAM/Lower/apu-timer", 0);}, 10);
					}

					setprop("/ECAM/Lower/page", "apu");

				} else if (((getprop("/engines/engine[0]/n2-actual") >= 59 or getprop("/engines/engine[1]/n2-actual") >= 59) and getprop("/gear/gear[1]/wow") == 1) or (getprop("/instrumentation/altimeter/indicated-altitude-ft") <= 16000 and getprop("/controls/gear/gear-down") == 1 and getprop("/gear/gear[1]/wow") == 0)) { 
					setprop("/ECAM/Lower/page", "wheel");

				} else if (getprop("/gear/gear[1]/wow") == 1) {
					setprop("/ECAM/Lower/page", "door");

				} else {
					setprop("/ECAM/Lower/page", "crz");
				}
			}
		}
	},
	reset: func() {
		setprop("/ECAM/Lower/page", "door");
		setprop("/ECAM/Lower/man-select", 0);
		setprop("/ECAM/Lower/fault-select", 0);
		setprop("/ECAM/Lower/apu-timer", 0);
		setprop("/ECAM/Lower/eng-timer", 0);
		setprop("/ECAM/Lower/eng-to", 0);
		setprop("/ECAM/Lower/fctl-timer", 0);
		setprop("/ECAM/Lower/light/apu", 0);
		setprop("/ECAM/Lower/light/bleed", 0);
		setprop("/ECAM/Lower/light/cond", 0);
		setprop("/ECAM/Lower/light/door", 0);
		setprop("/ECAM/Lower/light/elec", 0);
		setprop("/ECAM/Lower/light/eng", 0);
		setprop("/ECAM/Lower/light/fctl", 0);
		setprop("/ECAM/Lower/light/fuel", 0);
		setprop("/ECAM/Lower/light/hyd", 0);
		setprop("/ECAM/Lower/light/press", 0);
		setprop("/ECAM/Lower/light/sts", 0);
		setprop("/ECAM/Lower/light/wheel", 0);
	},
};
