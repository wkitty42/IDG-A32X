# A3XX Electronic Centralised Aircraft Monitoring System
# Jonathan Redpath (legoboyvdlp)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

# messages stored in vectors

var warnings                  = std.Vector.new([
	var lg_not_dn             = warning.new(msg: "L/G GEAR NOT DOWN",        active: 0, colour: "r", aural: "crc",   light: "warning", noRepeat: 0),
	var pack1_fault           = warning.new(msg: "AIR PACK 1 FAULT ",        active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0),
	var pack1_fault_subwarn_1 = warning.new(msg: "-PACK 1.............OFF ", active: 0, colour: "b", aural: "none",  light: "none",    noRepeat: 0),
	var pack2_fault           = warning.new(msg: "AIR PACK 2 FAULT ",        active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0),
	var pack2_fault_subwarn_1 = warning.new(msg: "-PACK 2.............OFF ", active: 0, colour: "b", aural: "none",  light: "none",    noRepeat: 0),
	var park_brk_on           = warning.new(msg: "PARK BRK ON",              active: 0, colour: "a", aural: "chime", light: "caution", noRepeat: 0)
]);

var leftmemos                 = std.Vector.new([
	var company_alert         = warning.new(msg: "COMPANY ALERT",            active: 0, colour: "g", aural: "buzz",  light: "none", noRepeat: 0), # Not yet implemented, buzzer sound
	var refuelg               = warning.new(msg: "REFUELG",                  active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var irs_in_align          = warning.new(msg: "IRS IN ALIGN",             active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0), # Not yet implemented
	var gnd_splrs             = warning.new(msg: "GND SPLRS ARMED",          active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var seatbelts             = warning.new(msg: "SEAT BELTS",               active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var nosmoke               = warning.new(msg: "NO SMOKING",               active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var strobe_lt_off         = warning.new(msg: "STROBE LT OFF",            active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var outr_tk_fuel_xfrd     = warning.new(msg: "OUTR TK FUEL XFRD",        active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0), # Not yet implemented
	var fob_3T                = warning.new(msg: "FOB BELOW 3T",             active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var gpws_flap_mode_off    = warning.new(msg: "GPWS FLAP MODE OFF",       active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0),
	var atc_datalink_stby     = warning.new(msg: "ATC DATALINK STBY",        active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0), # Not yet implemented
	var company_datalink_stby = warning.new(msg: "COMPANY DATALINK STBY",    active: 0, colour: "g", aural: "none",  light: "none", noRepeat: 0) # Not yet implemented
]);

var specialLines         = std.Vector.new([
	var to_inhibit       = memo.new(msg: "T.O. INHIBIT", active: 0, colour: "m"),
	var ldg_inhibit      = memo.new(msg: "LDG INHIBIT",  active: 0, colour: "m"),
	var land_asap_r      = memo.new(msg: "LAND ASAP",    active: 0, colour: "r"),
	var land_asap_a      = memo.new(msg: "LAND ASAP",    active: 0, colour: "a"),
	var ap_off           = memo.new(msg: "AP OFF",       active: 0, colour: "r"),
	var athr_off         = memo.new(msg: "A/THR OFF",    active: 0, colour: "a"),
]);

var secondaryFailures    = std.Vector.new([
	var secondary_bleed  = memo.new(msg: "•AIR BLEED",  active: 0, colour: "a"), # Not yet implemented
	var secondary_press  = memo.new(msg: "•CAB PRESS",  active: 0, colour: "a"), # Not yet implemented
	var secondary_vent   = memo.new(msg: "•AVNCS VENT", active: 0, colour: "a"), # Not yet implemented
	var secondary_elec   = memo.new(msg: "•ELEC",       active: 0, colour: "a"), # Not yet implemented
	var secondary_hyd    = memo.new(msg: "•HYD",        active: 0, colour: "a"), # Not yet implemented
	var secondary_fuel   = memo.new(msg: "•FUEL",       active: 0, colour: "a"), # Not yet implemented
	var secondary_cond   = memo.new(msg: "•AIR COND",   active: 0, colour: "a"), # Not yet implemented
	var secondary_brake  = memo.new(msg: "•BRAKES",     active: 0, colour: "a"), # Not yet implemented
	var secondary_wheel  = memo.new(msg: "•WHEEL",      active: 0, colour: "a"), # Not yet implemented
	var secondary_fctl   = memo.new(msg: "•F/CTL",      active: 0, colour: "a"), # Not yet implemented
]);

var memos                = std.Vector.new([
	var spd_brk          = memo.new(msg: "SPEED BRK",    active: 0, colour: "g"),  
	var park_brk         = memo.new(msg: "PARK BRK",     active: 0, colour: "g"),
	var ptu              = memo.new(msg: "HYD PTU",      active: 0, colour: "g"),
	var rat              = memo.new(msg: "RAT OUT",      active: 0, colour: "g"),
	var emer_gen         = memo.new(msg: "EMER GEN",     active: 0, colour: "g"),
	var ram_air          = memo.new(msg: "RAM AIR ON",   active: 0, colour: "g"),
	var nw_strg_disc     = memo.new(msg: "NW STRG DISC", active: 0, colour: "g"),
	var ignition         = memo.new(msg: "IGNITION",     active: 0, colour: "g"),
	var cabin_ready      = memo.new(msg: "CABIN READY",  active: 0, colour: "g"), # Not yet implemented
	var pred_ws_off      = memo.new(msg: "PRED W/S OFF", active: 0, colour: "g"), # Not yet implemented
	var terr_stby        = memo.new(msg: "TERR STBY",    active: 0, colour: "g"), # Not yet implemented
	var tcas_stby        = memo.new(msg: "TCAS STBY",    active: 0, colour: "g"), # Not yet implemented
	var acars_call       = memo.new(msg: "ACARS CALL",   active: 0, colour: "g"), # Not yet implemented
	var company_call     = memo.new(msg: "COMPANY CALL", active: 0, colour: "g"), # Not yet implemented
	var satcom_alert     = memo.new(msg: "SATCOM ALERT", active: 0, colour: "g"), # Not yet implemented
	var acars_msg        = memo.new(msg: "ACARS MSG",    active: 0, colour: "g"), # Not yet implemented
	var company_msg      = memo.new(msg: "COMPANY MSG",  active: 0, colour: "g"), # Not yet implemented
	var eng_aice         = memo.new(msg: "ENG A.ICE",    active: 0, colour: "g"),
	var wing_aice        = memo.new(msg: "WING A.ICE",   active: 0, colour: "g"),
	var ice_not_det      = memo.new(msg: "ICE NOT DET",  active: 0, colour: "g"), # Not yet implemented
	var hi_alt           = memo.new(msg: "HI ALT",       active: 0, colour: "g"), # Not yet implemented
	var apu_avail        = memo.new(msg: "APU AVAIL",    active: 0, colour: "g"),
	var apu_bleed        = memo.new(msg: "APU BLEED",    active: 0, colour: "g"),
	var ldg_lt           = memo.new(msg: "LDG LT",       active: 0, colour: "g"),
	var brk_fan          = memo.new(msg: "BRK FAN",      active: 0, colour: "g"), # Not yet implemented
	var audio3_xfrd      = memo.new(msg: "AUDIO 3 XFRD", active: 0, colour: "g"), # Not yet implemented
	var switchg_pnl      = memo.new(msg: "SWITCHG PNL",  active: 0, colour: "g"), # Not yet implemented
	var gpws_flap3       = memo.new(msg: "GPWS FLAP 3",  active: 0, colour: "g"), 
	var hf_data_ovrd     = memo.new(msg: "HF DATA OVRD", active: 0, colour: "g"), # Not yet implemented
	var hf_voice         = memo.new(msg: "HF VOICE",     active: 0, colour: "g"), # Not yet implemented
	var acars_stby       = memo.new(msg: "ACARS STBY",   active: 0, colour: "g"), # Not yet implemented
	var vhf3_voice       = memo.new(msg: "VHF3 VOICE",   active: 0, colour: "g"),
	var auto_brk_lo      = memo.new(msg: "AUTO BRK LO",  active: 0, colour: "g"),
	var auto_brk_med     = memo.new(msg: "AUTO BRK MED", active: 0, colour: "g"),
	var auto_brk_max     = memo.new(msg: "AUTO BRK MAX", active: 0, colour: "g"),
	var auto_brk_off     = memo.new(msg: "AUTO BRK OFF", active: 0, colour: "g"), # Not yet implemented
	var man_ldg_elev     = memo.new(msg: "MAN LDG ELEV", active: 0, colour: "g"), # Not yet implemented
	var ctr_tk_feedg     = memo.new(msg: "CTR TK FEEDG", active: 0, colour: "g"),
	var fuelx            = memo.new(msg: "FUEL X FEED",  active: 0, colour: "g")
]);

var clearWarnings        = std.Vector.new();
var statusLim            = std.Vector.new();
var statusApprProc       = std.Vector.new();
var statusProc           = std.Vector.new();
var statusInfo           = std.Vector.new();
var statusCancelled      = std.Vector.new();
var statusInop           = std.Vector.new();
var statusMaintenance    = std.Vector.new();