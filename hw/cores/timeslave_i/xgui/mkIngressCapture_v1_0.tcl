# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Stream_Width" -parent ${Page_0}


}

proc update_PARAM_VALUE.Stream_Width { PARAM_VALUE.Stream_Width } {
	# Procedure called to update Stream_Width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Stream_Width { PARAM_VALUE.Stream_Width } {
	# Procedure called to validate Stream_Width
	return true
}


proc update_MODELPARAM_VALUE.Stream_Width { MODELPARAM_VALUE.Stream_Width PARAM_VALUE.Stream_Width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Stream_Width}] ${MODELPARAM_VALUE.Stream_Width}
}

