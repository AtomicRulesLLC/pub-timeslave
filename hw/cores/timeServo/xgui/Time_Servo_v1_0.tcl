# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "NumCDC" -widget comboBox

}

proc update_PARAM_VALUE.NumCDC { PARAM_VALUE.NumCDC } {
	# Procedure called to update NumCDC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NumCDC { PARAM_VALUE.NumCDC } {
	# Procedure called to validate NumCDC
	return true
}


