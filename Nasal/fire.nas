# A3XX Fire System
# Jonathan Redpath

# Copyright (c) 2019 Joshua Davidson (it0uchpods)

#############
# Init Vars #
#############

var level = 0;
var fwdsquib = 0;
var aftsquib = 0;
var fwddet = 0;
var aftdet = 0;
var test = 0;
var guard1 = 0;
var guard2 = 0;
var dischpb1 = 0;
var dischpb2 = 0;
var smokedet1 = 0;
var smokedet2 = 0;
var bottleIsEmpty = 0;
var WeCanExt = 0;
var test2 = 0;
var state = 0;
var dc1 = 0;
var dc2 = 0;
var dcbat = 0;
var pause = 0;
var et = 0;

var elapsedTime = props.globals.getNode("/sim/time/elapsed-sec");
var apuTestBtn = props.globals.getNode("/controls/fire/apu-test-btn", 1);
var testBtn = props.globals.getNode("/controls/fire/test-btn-1", 1);
var testBtn2 = props.globals.getNode("/controls/fire/test-btn-2", 1);
var eng1FireWarn = props.globals.initNode("/systems/fire/engine1/warning-active", 0, "BOOL");
var eng2FireWarn = props.globals.initNode("/systems/fire/engine2/warning-active", 0, "BOOL");
var apuFireWarn = props.globals.initNode("/systems/fire/apu/warning-active", 0, "BOOL");
var wow = props.globals.getNode("/fdm/jsbsim/position/wow", 1);
var dcbatNode = props.globals.getNode("systems/electrical/bus/dcbat", 1);
var dcessNode = props.globals.getNode("systems/electrical/bus/dc-ess", 1);

var fire_init = func {
	setprop("/controls/OH/protectors/fwddisch", 0);
	setprop("/controls/OH/protectors/aftdisch", 0);
	setprop("/systems/failures/cargo-fwd-fire", 0);
	setprop("/systems/failures/cargo-aft-fire", 0);
	setprop("/systems/fire/cargo/fwdsquib", 0);
	setprop("/systems/fire/cargo/aftsquib", 0);
	setprop("/systems/fire/cargo/bottlelevel", 100);
	setprop("/systems/fire/cargo/test", 0);
	setprop("/controls/fire/cargo/test", 0);
	setprop("/controls/fire/cargo/fwddisch", 0); # pushbutton
	setprop("/controls/fire/cargo/aftdisch", 0);
	setprop("/controls/fire/cargo/fwddischLight", 0);
	setprop("/controls/fire/cargo/aftdischLight", 0);
	setprop("/controls/fire/cargo/fwdsmokeLight", 0);
	setprop("/controls/fire/cargo/aftsmokeLight", 0);
	setprop("/controls/fire/cargo/bottleempty", 0);
	# status: 1 is ready, 0 is already disch
	setprop("/controls/fire/cargo/status", 1);
	setprop("/controls/fire/cargo/warnfwd", 0);
	setprop("/controls/fire/cargo/warnaft", 0);
	setprop("/controls/fire/cargo/squib1fault", 0);
	setprop("/controls/fire/cargo/squib2fault", 0);
	setprop("/controls/fire/cargo/detfault", 0);
	setprop("/controls/fire/cargo/test/state", 0);
	fire_timer.start();
}

##############
# Main Loops #
##############
var master_fire = func {
	level = getprop("/systems/fire/cargo/bottlelevel");
	fwdsquib = getprop("/systems/fire/cargo/fwdsquib");
	aftsquib = getprop("/systems/fire/cargo/aftsquib");
	fwddet = getprop("/systems/failures/cargo-fwd-fire");
	aftdet = getprop("/systems/failures/cargo-aft-fire");
	test = getprop("/controls/fire/cargo/test");
	guard1 = getprop("/controls/fire/cargo/fwdguard");
	guard2 = getprop("/controls/fire/cargo/aftguard");
	dischpb1 = getprop("/controls/fire/cargo/fwddisch"); 
	dischpb2 = getprop("/controls/fire/cargo/aftdisch");
	smokedet1 = getprop("/controls/fire/cargo/fwdsmokeLight");
	smokedet2 = getprop("/controls/fire/cargo/aftsmokeLight");
	bottleIsEmpty = getprop("/controls/fire/cargo/bottleempty");
	WeCanExt = getprop("/controls/fire/cargo/status");
	test2 = getprop("/systems/fire/cargo/test");
	state = getprop("/controls/fire/cargo/test/state");
	dc1 = getprop("/systems/electrical/bus/dc1");
	dc2 = getprop("/systems/electrical/bus/dc2");
	dcbat = dcbatNode.getValue();
	pause = getprop("/sim/freeze/master");
	
	###############
	# Discharging #
	###############
	
	if (dischpb1) {
		if (WeCanExt == 1 and !fwdsquib and !bottleIsEmpty and (dc1 > 0 or dc2 > 0 or dcbat > 0)) {
			setprop("/systems/fire/cargo/fwdsquib", 1);
		}
	}
	
	if (dischpb1 and fwdsquib and !bottleIsEmpty and !pause) {
		setprop("/systems/fire/cargo/bottlelevel", getprop("/systems/fire/cargo/bottlelevel") - 0.33);
	}
	
	if (dischpb2) {
		if (WeCanExt == 1 and !aftsquib and !bottleIsEmpty and (dc1 > 0 or dc2 > 0 or dcbat > 0)) {
			setprop("/systems/fire/cargo/aftsquib", 1);
		}
	} 
	
	if (dischpb2 and aftsquib and !bottleIsEmpty and !pause) {
		setprop("/systems/fire/cargo/bottlelevel", getprop("/systems/fire/cargo/bottlelevel") - 0.33);
	}
	
	#################
	# Test Sequence #
	#################
	
	if (test) {
		setprop("/systems/fire/cargo/test", 1);
	} else {
		setprop("/systems/fire/cargo/test", 0);
	}
	
	if (test2 and state == 0) {
		setprop("/controls/fire/cargo/fwddischLight", 1);
		setprop("/controls/fire/cargo/aftdischLight", 1);
		settimer(func(){
			setprop("/controls/fire/cargo/fwddischLight", 0);
			setprop("/controls/fire/cargo/aftdischLight", 0);
			setprop("/controls/fire/cargo/test/state", 1);
		}, 5);
	} else if (test2 and state == 1) {
		setprop("/controls/fire/cargo/fwdsmokeLight", 1);
		setprop("/controls/fire/cargo/warnfwd", 1);
		setprop("/controls/fire/cargo/aftsmokeLight", 1);
		setprop("/controls/fire/cargo/warnaft", 1);
		settimer(func(){
			setprop("/controls/fire/cargo/fwdsmokeLight", 0);
			setprop("/controls/fire/cargo/aftsmokeLight", 0);
			setprop("/controls/fire/cargo/warnfwd", 0);
			setprop("/controls/fire/cargo/warnaft", 0);
			setprop("/controls/fire/cargo/test/state", 2);
		}, 5);
	} else if (test2 and state == 2) {
		settimer(func(){
			setprop("/controls/fire/cargo/test/state", 3);
		}, 5);
	} else if (test2 and state == 3) {
		setprop("/controls/fire/cargo/fwdsmokeLight", 1);
		setprop("/controls/fire/cargo/warnfwd", 1);
		setprop("/controls/fire/cargo/aftsmokeLight", 1);
		setprop("/controls/fire/cargo/warnaft", 1);
		settimer(func(){
			setprop("/controls/fire/cargo/fwdsmokeLight", 0);
			setprop("/controls/fire/cargo/aftsmokeLight", 0);
			setprop("/controls/fire/cargo/warnfwd", 0);
			setprop("/controls/fire/cargo/warnaft", 0);
			setprop("/systems/fire/cargo/test", 0);
			setprop("/controls/fire/cargo/test", 0);
			setprop("/controls/fire/cargo/test/state", 0);
		}, 5);
	}
	
	
	##########
	# Status #
	##########
	
	if (level < 0.1 and !test) {
		setprop("/controls/fire/cargo/bottleempty", 1);
		setprop("/controls/fire/cargo/status", 0);
		setprop("/controls/fire/cargo/fwddischLight", 1);
		setprop("/controls/fire/cargo/aftdischLight", 1);
	} else if (!test) {
		setprop("/controls/fire/cargo/bottleempty", 0);
		setprop("/controls/fire/cargo/status", 1);
		setprop("/controls/fire/cargo/fwddischLight", 0);
		setprop("/controls/fire/cargo/aftdischLight", 0);
	}
}

###################
# Detection Logic #
###################

setlistener("/systems/failures/cargo-fwd-fire", func() {
	if (getprop("/systems/failures/cargo-fwd-fire")) {
		setprop("/controls/fire/cargo/fwdsmokeLight", 1);
		setprop("/controls/fire/cargo/warnfwd", 1);
	} else {
		setprop("/controls/fire/cargo/fwdsmokeLight", 0);
	}
}, 0, 0);

setlistener("/systems/failures/cargo-aft-fire", func() {
	if (getprop("/systems/failures/cargo-aft-fire")) {
		setprop("/controls/fire/cargo/aftsmokeLight", 1);
		setprop("/controls/fire/cargo/warnaft", 1);
	} else {
		setprop("/controls/fire/cargo/aftsmokeLight", 0);
	}
}, 0, 0);

###################
# Engine Fire     #
###################
var engFireDetectorUnit = {
	sys: 0,
	active: 0,
	loopOne: 0,
	loopTwo: 0,
	condition: 100,
	wow: "",
	new: func(sys) {
		var eF = {parents:[engFireDetectorUnit]};
		eF.sys = sys;
		eF.active = 0;
		eF.loopOne = 0;
		eF.loopTwo = 0;
		eF.wow = props.globals.getNode("/fdm/jsbsim/position/wow", 1);
		return eF;
	},
	update: func() {
		if (me.condition == 0) { return; }
		
		foreach(var detector; detectorLoops.vector) {
			detector.updateTemp(detector.sys, detector.type);
		}
		
		if ((me.loopOne == 1 and me.loopTwo == 1) or ((me.loopOne == 9 or me.loopOne == 8) and me.loopTwo == 1)  or (me.loopOne == 1 and (me.loopTwo == 9 or me.loopTwo == 8))) {
			me.TriggerWarning(me.sys);
		}
	},
	receiveSignal: func(type) {
		if (type == 1 and me.loopOne != 9 and me.condition != 0) {
			me.loopOne = 1;
		} elsif (type == 2 and me.loopTwo != 9 and me.condition != 0) {
			me.loopTwo = 1;
		}
	},
	failUnit: func() {
		me.condition = 0;
	},
	fail: func(loop) {
		if (loop != 1 and loop != 2) { return; }
		
		if (loop == 1) { me.loopOne = 9; }
		else { me.loopTwo = 9; }
		
		me.startFailTimer(loop);
	},
	noElec: func(loop) {
		if (loop != 1 and loop != 2) { return; }
	
		if (loop == 1) { me.loopOne = 8; }
		else { me.loopTwo = 8; }
	},
	startFailTimer: func(loop) {
		if (me.sys != 2) {
			if (loop == 1) {
				propsNasFireTime.vector[sys].setValue(elapsedTime.getValue());
			} elsif (loop == 2) {
				propsNasFireTime.vector[sys + 1].setValue(elapsedTime.getValue());
			}
		} else {
			if (loop == 1) {
				propsNasFireTime.vector[4].setValue(elapsedTime.getValue());
			} elsif (loop == 2) {
				propsNasFireTime.vector[5].setValue(elapsedTime.getValue());
			}
		}
		
		if (!fireTimer.isRunning) {
			fireTimer.start();
		}
	},
	TriggerWarning: func(system) {
		if (system == 0) {
			eng1FireWarn.setBoolValue(1);
		} elsif (system == 1) {
			eng2FireWarn.setBoolValue(1);
		} elsif (system == 2) {
			apuFireWarn.setBoolValue(1);
			if (me.wow.getValue() == 1) {
				extinguisherBottles.vector[4].discharge();
			}
		}
	}
};

var detectorLoop = {
	sys: 9,
	type: 0,
	temperature: "",
	elecProp: "",
	new: func(sys, type, temperature, elecProp) {
		var dL = {parents:[detectorLoop]};
		dL.sys = sys;
		dL.type = type;
		dL.temperature = temperature;
		dL.elecProp = props.globals.getNode(elecProp, 1);
		
		return dL;
	},
	updateTemp: func(system, typeLoop) {
		var index = 0;
		if (system == 1) { index += 2 } 
		elsif (system == 2) { index += 4 }
		
		if (typeLoop == 1) { index += 1 }
		
		if (propsNasFire.vector[index].getValue() > 250 and me.elecProp.getValue() >= 25) {
			me.sendSignal(system, typeLoop);
		} elsif (me.elecProp.getValue() < 25) {
			engFireDetectorUnits.vector[system].noElec(typeLoop);
		}
	},
	sendSignal: func(system, typeLoop) {
		if (system == 0 and !getprop("/systems/failures/engine-left-fire")) { return; }
		elsif (system == 1 and !getprop("/systems/failures/engine-right-fire")) { return; }
		elsif (system == 2 and !getprop("/systems/failures/apu-fire")) { return; }
		
		engFireDetectorUnits.vector[system].receiveSignal(typeLoop);
	}
};

var extinguisherBottle = {
	quantity: 100,
	squib: 0,
	number: 0,
	lightProp: "",
	elecProp: "",
	failProp: "",
	warningProp: "",
	new: func(number, lightProp, elecProp, failProp, warningProp) {
		var eB = {parents:[extinguisherBottle]};
		eB.quantity = 100;
		eB.squib = 0;
		eB.number = number;
		eB.lightProp = props.globals.getNode(lightProp, 1);
		eB.elecProp = props.globals.getNode(elecProp, 1);
		eB.failProp = props.globals.getNode(failProp, 1);
		eB.warningProp = props.globals.getNode(warningProp, 1);
		return eB;
	},
	emptyBottle: func() {
		me.quantity -= 1;
		if (me.quantity > 0) { 
			settimer(func() {
				me.emptyBottle()
			}, 0.05); 
		} else {
			me.lightProp.setValue(1);
			# make things interesting. If your fire won't go out you should play the lottery
			if (me.number == 0) {
				if (rand() < 0.75) { 
					me.failProp.setValue(0);
					me.warningProp.setValue(0);
				}
			} elsif (me.number == 1) {
				if (rand() < 0.98) {
					me.failProp.setValue(0);
					me.warningProp.setValue(0);
				}
			} elsif (me.number == 9) {
				if (rand() <= 0.999) {
					me.failProp.setValue(0);
					me.warningProp.setValue(0);
				}
			}
		}
	},
	discharge: func() {
		if (me.elecProp.getValue() < 25) { return; }
		me.squib = 1;
		me.emptyBottle();
	}
};

# If two loops fail within five seconds then assume there is a fire

var propsNasFireTime = std.Vector.new([
props.globals.getNode("/systems/fire/engine1/loop1-failtime", 1), props.globals.getNode("/systems/fire/engine1/loop2-failtime", 1),
props.globals.getNode("/systems/fire/engine2/loop1-failtime", 1), props.globals.getNode("/systems/fire/engine2/loop2-failtime", 1),
props.globals.getNode("/systems/fire/apu/loop1-failtime", 1), props.globals.getNode("/systems/fire/apu/loop2-failtime", 1)
]);

var checkTimeFire1 = func() {
	et = elapsedTime.getValue();
	var loop1 = propsNasFireTime.vector[0].getValue();
	var loop2 = propsNasFireTime.vector[1].getValue();
	
	if ((loop1 != 0 and et > loop1 + 5) or (loop2 != 0 and et > loop2 + 5))  {
		fireTimer1.stop();
		loop1.setValue(0);
		loop2.setValue(0);
	}
	
	if (engFireDetectorUnits.vector[0].loop1 == 9 and engFireDetectorUnits.vector[0].loop2 == 9) {
		fireTimer1.stop();
		engFireDetectorUnits.vector[0].TriggerWarning(engFireDetectorUnits.vector[0].sys);
		loop1.setValue(0);
		loop2.setValue(0);
	}
}

var checkTimeFire2 = func() {
	et = elapsedTime.getValue();
	var loop3 = propsNasFireTime.vector[2].getValue();
	var loop4 = propsNasFireTime.vector[3].getValue();
	
	if ((loop3 != 0 and et > loop3 + 5) or (loop4 != 0 and et > loop4 + 5))  {
		fireTimer2.stop();
		loop3.setValue(0);
		loop4.setValue(0);
	}
	
	if (engFireDetectorUnits.vector[1].loop1 == 9 and engFireDetectorUnits.vector[1].loop2 == 9) {
		fireTimer2.stop();
		engFireDetectorUnits.vector[1].TriggerWarning(engFireDetectorUnits.vector[1].sys);
		loop3.setValue(0);
		loop4.setValue(0);
	}
}

var checkTimeFire3 = func() {
	et = elapsedTime.getValue();
	var loop4 = propsNasFireTime.vector[3].getValue();
	var loop5 = propsNasFireTime.vector[4].getValue();
	
	if ((loop4 != 0 and et > loop4 + 5) or (loop5 != 0 and et > loop5 + 5)) {
		fireTimer3.stop();
		loop4.setValue(0);
		loop5.setValue(0);
	}
	
	if (engFireDetectorUnits.vector[2].loop1 == 9 and engFireDetectorUnits.vector[2].loop2 == 9) {
		fireTimer3.stop();
		engFireDetectorUnits.vector[2].TriggerWarning(engFireDetectorUnits.vector[2].sys);
		loop4.setValue(0);
		loop5.setValue(0);
	}
}

var fireTimer1 = maketimer(0.25, checkTimeFire1);
fireTimer1.simulatedTime = 1;
var fireTimer2 = maketimer(0.25, checkTimeFire2);
fireTimer2.simulatedTime = 1;
var fireTimer3 = maketimer(0.25, checkTimeFire3);
fireTimer3.simulatedTime = 1;

# Create engine fire systems
var engFireDetectorUnits = std.Vector.new([ engFireDetectorUnit.new(0), engFireDetectorUnit.new(1), engFireDetectorUnit.new(2) ]);

# Create detector loops
var detectorLoops = std.Vector.new([ 
detectorLoop.new(0, 1, "/systems/fire/engine1/temperature", "/systems/electrical/bus/dc-ess"), detectorLoop.new(0, 2, "/systems/fire/engine1/temperature", "/systems/electrical/bus/dc2"),
detectorLoop.new(1, 1, "/systems/fire/engine2/temperature", "/systems/electrical/bus/dc2"),    detectorLoop.new(1, 2, "/systems/fire/engine2/temperature", "/systems/electrical/bus/dc-ess"),
detectorLoop.new(2, 1, "/systems/fire/apu/temperature", "/systems/electrical/bus/dcbat"),      detectorLoop.new(2, 2, "/systems/fire/apu/temperature", "/systems/electrical/bus/dcbat") 
]);

# Create extinguisher bottles
var extinguisherBottles = std.Vector.new([extinguisherBottle.new(0, "/systems/fire/engine1/disch1", "/systems/electrical/bus/dcbat", "/systems/failures/engine-left-fire", "/systems/fire/engine1/warning-active"), extinguisherBottle.new(1, "/systems/fire/engine1/disch2", "/systems/electrical/bus/dc2", "/systems/failures/engine-left-fire", "/systems/fire/engine1/warning-active"),
extinguisherBottle.new(0, "/systems/fire/engine2/disch1", "/systems/electrical/bus/dcbat", "/systems/failures/engine-right-fire", "/systems/fire/engine2/warning-active"), extinguisherBottle.new(1, "/systems/fire/engine2/disch2", "/systems/electrical/bus/dc2", "/systems/failures/engine-right-fire", "/systems/fire/engine2/warning-active"), 
extinguisherBottle.new(9, "/systems/fire/apu/disch", "/systems/electrical/bus/dcbat", "/systems/failures/apu-fire", "/systems/fire/apu/warning-active") ]);

# Props.nas helper
var propsNasFire = std.Vector.new();
foreach (detectorLoop; detectorLoops.vector) {
	propsNasFire.append(props.globals.getNode(detectorLoop.temperature));
};

# Setlistener helper
var createFireBottleListener = func(prop, fireBtnProp, index) {
	if (index >= extinguisherBottles.size()) {
		print("Error - calling listener on non-existent fire extinguisher bottle, index: " ~ index); 
		return;
	}
	
	setlistener(prop, func() {
		if (getprop(prop) == 1 and getprop(fireBtnProp) == 1) {
			extinguisherBottles.vector[index].discharge();
		}
	}, 0, 0);
}

# Listeners 
setlistener("/controls/engines/engine[0]/fire-btn", func() { 
	if (getprop("/controls/engines/engine[0]/fire-btn") == 1) { 
		ecam.shutUpYou();
	}
}, 0, 0);

setlistener("/controls/engines/engine[1]/fire-btn", func() { 
	if (getprop("/controls/engines/engine[1]/fire-btn") == 1) { 
		ecam.shutUpYou(); 
	}
}, 0, 0);

setlistener("/controls/APU/fire-btn", func() { 
	if (getprop("/controls/APU/fire-btn") == 1) { 
		ecam.shutUpYou(); 
	}
}, 0, 0);

setlistener("/controls/fire/test-btn-1", func() {
	if (getprop("/systems/failures/engine-left-fire")) { return; }
	
	if (testBtn.getValue() == 1) {
		if (dcbatNode.getValue() > 25 or dcessNode.getValue() > 25) {
			eng1FireWarn.setBoolValue(1);
		} else {
			eng1FireWarn.setBoolValue(0);
		}
	} else {
		eng1FireWarn.setBoolValue(0);
	}
}, 0, 0);

setlistener("/controls/fire/test-btn-2", func() {
	if (getprop("/systems/failures/engine-right-fire")) { return; }
	if (testBtn2.getValue() == 1) {
		if (dcbatNode.getValue() > 25 or dcessNode.getValue() > 25) {
			eng2FireWarn.setBoolValue(1);
		} else {
			eng2FireWarn.setBoolValue(0);
		}
	} else {
		eng2FireWarn.setBoolValue(0);
	}
}, 0, 0);

setlistener("/controls/fire/apu-test-btn", func() {
	if (getprop("/systems/failures/apu-fire")) { return; }
	if (apuTestBtn.getValue() == 1) {
		if (dcbatNode.getValue() > 25 or dcessNode.getValue() > 25) {
			apuFireWarn.setBoolValue(1);
		} else {
			apuFireWarn.setBoolValue(0);
		}
	} else {
		apuFireWarn.setBoolValue(0);
	}
}, 0, 0);

createFireBottleListener("/controls/engines/engine[0]/agent1-btn", "/controls/engines/engine[0]/fire-btn", 0);
createFireBottleListener("/controls/engines/engine[0]/agent2-btn", "/controls/engines/engine[0]/fire-btn", 1);
createFireBottleListener("/controls/engines/engine[1]/agent1-btn", "/controls/engines/engine[1]/fire-btn", 2);
createFireBottleListener("/controls/engines/engine[1]/agent2-btn", "/controls/engines/engine[1]/fire-btn", 3);
createFireBottleListener("/controls/APU/agent-btn", "/controls/APU/fire-btn", 4);

var updateUnits = func() {
	foreach (var units; engFireDetectorUnits.vector) {
		units.update();
	}
}

###################
# Update Function #
###################

var update_fire = func() {
	master_fire();
	updateUnits();
}

var fire_timer = maketimer(0.2, update_fire);