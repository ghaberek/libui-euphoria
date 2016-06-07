include std/dll.e
include std/machine.e
include std/error.e
include std/map.e

export constant NULL = dll:NULL

ifdef EU4_0 then
-- sizeof() is not declared in Euphoria 4.0

function sizeof( atom ctype )
	return and_bits( ctype, #FF )
end function

end ifdef



map id_lookup = map:new()

function define_c_func( atom lib, sequence name, sequence ptypes, atom rtype )

	atom id = dll:define_c_func( lib, "+" & name, ptypes, rtype )
	if id = -1 then error:crash( "%s not found", {name} ) end if
	map:put( id_lookup, name, id )

	return id
end function

function define_c_proc( atom lib, sequence name, sequence ptypes )

	atom id = dll:define_c_proc( lib, "+" & name, ptypes )
	if id = -1 then error:crash( "%s not found", {name} ) end if
	map:put( id_lookup, name, id )

	return id
end function

function c_func( object func, sequence params )

	if sequence( func ) then
		func = map:get( id_lookup, func, -1 )
	end if

	return eu:c_func( func, params )
end function

procedure c_proc( object proc, sequence params )

	if sequence( proc ) then
		proc = map:get( id_lookup, proc, -1 )
	end if

	eu:c_proc( proc, params )
end procedure



atom libui = open_dll({ "libui.dll", "libui.so.0", "libui.A.dylib" })
if libui = NULL then error:crash( "libui not found" ) end if



define_c_func( libui, "uiInit", {C_POINTER}, C_POINTER )
public function uiInit( atom options = NULL )

	if options = NULL then
		options = allocate_data( sizeof(C_SIZE_T), 1 )
		mem_set( options, NULL, sizeof(C_SIZE_T) )
	end if

	atom err = c_func( "uiInit", {options} )
	if err != NULL then
		sequence str = peek_string( err )
		uiFreeInitError( err )
		return str
	end if

	return err
end function

define_c_proc( libui, "uiUninit", {} )
public procedure uiUninit()
	c_proc( "uiUninit", {} )
end procedure

define_c_proc( libui, "uiFreeInitError", {C_POINTER} )
public procedure uiFreeInitError( atom err )
	c_proc( "uiFreeInitError", {err} )
end procedure



define_c_proc( libui, "uiMain", {} )
public procedure uiMain()
	c_proc( "uiMain", {} )
end procedure

define_c_func( libui, "uiMainStep", {C_INT}, C_INT )
public function uiMainStep( atom wait )
	return c_func( "uiMainStep", wait )
end function

define_c_proc( libui, "uiQuit", {} )
public procedure uiQuit()
	c_proc( "uiQuit", {} )
end procedure



define_c_proc( libui, "uiQueueMain", {C_POINTER,C_POINTER} )
public procedure uiQueueMain( object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiQueueMain", {call_back(id),data} )
end procedure

define_c_proc( libui, "uiOnShouldQuit", {C_POINTER,C_POINTER} )
public procedure uiOnShouldQuit( object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiOnShouldQuit", {call_back(id),data} )
end procedure

define_c_proc( libui, "uiFreeText", {C_POINTER} )
public procedure uiFreeText( atom text )
	c_proc( "uiFreeText", {text} )
end procedure



define_c_proc( libui, "uiControlDestroy", {C_POINTER} )
public procedure uiControlDestroy( atom c )
	c_proc( "uiControlDestroy", {c} )
end procedure

define_c_func( libui, "uiControlHandle", {C_POINTER}, C_POINTER )
public function uiControlHandle( atom c )
	return c_func( "uiControlHandle", {c} )
end function

define_c_func( libui, "uiControlParent", {C_POINTER}, C_POINTER )
public function uiControlParent( atom c )
	return c_func( "uiControlParent", {c} )
end function

define_c_proc( libui, "uiControlSetParent", {C_POINTER,C_POINTER} )
public procedure uiControlSetParent( atom c, atom parent )
	c_proc( "uiControlSetParent", {c,parent} )
end procedure

define_c_func( libui, "uiControlToplevel", {C_POINTER}, C_INT )
public function uiControlToplevel( atom c )
	return c_func( "uiControlToplevel", {c} )
end function

define_c_func( libui, "uiControlVisible", {C_POINTER}, C_INT )
public function uiControlVisible( atom c )
	return c_func( "uiControlVisible", {c} )
end function

define_c_proc( libui, "uiControlShow", {C_POINTER} )
public procedure uiControlShow( atom c )
	c_proc( "uiControlShow", {c} )
end procedure

define_c_proc( libui, "uiControlHide", {C_POINTER} )
public procedure uiControlHide( atom c )
	c_proc( "uiControlHide", {c} )
end procedure

define_c_func( libui, "uiControlEnabled", {C_POINTER}, C_INT )
public function uiControlEnabled( atom c )
	return c_func( "uiControlEnabled", {c} )
end function

define_c_proc( libui, "uiControlEnable", {C_POINTER} )
public procedure uiControlEnable( atom c )
	c_proc( "uiControlEnable", {c} )
end procedure

define_c_proc( libui, "uiControlDisable", {C_POINTER} )
public procedure uiControlDisable( atom c )
	c_proc( "uiControlDisable", {c} )
end procedure



define_c_func( libui, "uiAllocControl", {C_SIZE_T,C_UINT,C_UINT,C_POINTER}, C_POINTER )
public function uiAllocControl( atom n, atom OSsig, atom typesig, sequence typenamestr )
	return c_func( "uiAllocControl", {n,OSsig,typesig,allocate_string(typenamestr,1)} )
end function

define_c_proc( libui, "uiFreeControl", {C_POINTER} )
public procedure uiFreeControl( atom c )
	c_proc( "uiFreeControl", {c} )
end procedure



define_c_func( libui, "uiWindowTitle", {C_POINTER}, C_POINTER )
public function uiWindowTitle( atom w )
	atom ptr = c_func( "uiWindowTitle", {w} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiWindowSetTitle", {C_POINTER,C_POINTER} )
public procedure uiWindowSetTitle( atom w, sequence title )
	c_proc( "uiWindowSetTitle", {w,allocate_string(title)} )
end procedure

define_c_proc( libui, "uiWindowOnClosing", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiWindowOnClosing( atom w, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiWindowOnClosing", {w,call_back(id),data} )
end procedure

define_c_proc( libui, "uiWindowSetChild", {C_POINTER,C_POINTER} )
public procedure uiWindowSetChild( atom w, atom child )
	c_proc( "uiWindowSetChild", {w,child} )
end procedure

define_c_func( libui, "uiWindowMargined", {C_POINTER}, C_INT )
public function uiWindowMargined( atom w )
	return c_func( "uiWindowMargined", {w} )
end function

define_c_proc( libui, "uiWindowSetMargined", {C_POINTER,C_INT} )
public procedure uiWindowSetMargined( atom w, atom margined )
	c_proc( "uiWindowSetMargined", {w,margined} )
end procedure

define_c_func( libui, "uiNewWindow", {C_POINTER,C_INT,C_INT,C_INT}, C_POINTER )
public function uiNewWindow( sequence title, atom width, atom height, atom hasMenubar )
	return c_func( "uiNewWindow", {allocate_string(title,1),width,height,hasMenubar} )
end function



define_c_func( libui, "uiButtonText", {C_POINTER}, C_POINTER )
public function uiButtonText( atom b )
	atom ptr = c_func( "uiButtonText", {b} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiButtonSetText", {C_POINTER,C_POINTER} )
public procedure uiButtonSetText( atom b, sequence text )
	c_proc( "uiButtonSetText", {b,allocate_string(text,1)} )
end procedure

define_c_proc( libui, "uiButtonOnClicked", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiButtonOnClicked( atom b, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiButtonOnClicked", {b,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewButton", {C_POINTER}, C_POINTER )
public function uiNewButton( sequence text )
	return c_func( "uiNewButton", {allocate_string(text,1)} )
end function



define_c_proc( libui, "uiBoxAppend", {C_POINTER,C_POINTER,C_INT} )
public procedure uiBoxAppend( atom b, atom child, atom stretchy )
	c_proc( "uiBoxAppend", {b,child,stretchy} )
end procedure

define_c_proc( libui, "uiBoxDelete", {C_POINTER,C_UINT} )
public procedure uiBoxDelete( atom b, atom index )
	c_proc( "uiBoxDelete", {b,index} )
end procedure

define_c_func( libui, "uiBoxPadded", {C_POINTER}, C_INT )
public function uiBoxPadded( atom b )
	return c_func( "uiBoxPadded", {b} )
end function

define_c_proc( libui, "uiBoxSetPadded", {C_POINTER,C_INT} )
public procedure uiBoxSetPadded( atom b, atom padded )
	c_proc( "uiBoxSetPadded", {b,padded} )
end procedure

define_c_func( libui, "uiNewHorizontalBox", {}, C_POINTER )
public function uiNewHorizontalBox()
	return c_func( "uiNewHorizontalBox", {} )
end function

define_c_func( libui, "uiNewVerticalBox", {}, C_POINTER )
public function uiNewVerticalBox()
	return c_func( "uiNewVerticalBox", {} )
end function



define_c_func( libui, "uiCheckboxText", {C_POINTER}, C_POINTER )
public function uiCheckboxText( atom c )
	atom ptr = c_func( "uiCheckboxText", {c} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiCheckboxSetText", {C_POINTER,C_POINTER} )
public procedure uiCheckboxSetText( atom c, sequence text )
	c_proc( "uiCheckboxSetText", {c,allocate_string(text,1)} )
end procedure

define_c_proc( libui, "uiCheckboxOnToggled", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiCheckboxOnToggled( atom c, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiCheckboxOnToggled", {c,call_back(id),data} )
end procedure

define_c_func( libui, "uiCheckboxChecked", {C_POINTER}, C_INT )
public function uiCheckboxChecked( atom c )
	return c_func( "uiCheckboxChecked", {c} )
end function

define_c_proc( libui, "uiCheckboxSetChecked", {C_POINTER,C_INT} )
public procedure uiCheckboxSetChecked( atom c, atom checked )
	c_proc( "uiCheckboxSetChecked", {c,checked} )
end procedure

define_c_func( libui, "uiNewCheckbox", {C_POINTER}, C_POINTER )
public function uiNewCheckbox( sequence text )
	return c_func( "uiNewCheckbox", {allocate_string(text)} )
end function



define_c_func( libui, "uiEntryText", {C_POINTER}, C_POINTER )
public function uiEntryText( atom e )
	atom ptr = c_func( "uiEntryText", {e} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiEntrySetText", {C_POINTER,C_POINTER} )
public procedure uiEntrySetText( atom e, sequence text )
	c_proc( "uiEntrySetText", {e,allocate_string(text,1)} )
end procedure

define_c_proc( libui, "uiEntryOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiEntryOnChanged( atom e, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiEntryOnChanged", {e,call_back(id),data} )
end procedure

define_c_func( libui, "uiEntryReadOnly", {C_POINTER}, C_INT )
public function uiEntryReadOnly( atom e )
	return c_func( "uiEntryReadOnly", {e} )
end function

define_c_proc( libui, "uiEntrySetReadOnly", {C_POINTER,C_INT} )
public procedure uiEntrySetReadOnly( atom e, atom readonly )
	c_proc( "uiEntrySetReadOnly", {e,readonly} )
end procedure

define_c_func( libui, "uiNewEntry", {}, C_POINTER )
public function uiNewEntry()
	return c_func( "uiNewEntry", {} )
end function

define_c_func( libui, "uiNewPasswordEntry", {}, C_POINTER )
public function uiNewPasswordEntry()
	return c_func( "uiNewPasswordEntry", {} )
end function

define_c_func( libui, "uiNewSearchEntry", {}, C_POINTER )
public function uiNewSearchEntry()
	return c_func( "uiNewSearchEntry", {} )
end function



define_c_func( libui, "uiLabelText", {C_POINTER}, C_POINTER )
public function uiLabelText( atom l )
	atom ptr = c_func( "uiLabelText", {l} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiLabelSetText", {C_POINTER,C_POINTER} )
public procedure uiLabelSetText( atom l, sequence text )
	c_proc( "uiLabelSetText", {l,allocate_string(text,1)} )
end procedure

define_c_func( libui, "uiNewLabel", {C_POINTER}, C_POINTER )
public function uiNewLabel( sequence text )
	return c_func( "uiNewLabel", {allocate_string(text,1)} )
end function



define_c_proc( libui, "uiTabAppend", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiTabAppend( atom t, sequence name, atom c )
	c_proc( "uiTabAppend", {t,allocate_string(name,1),c} )
end procedure

define_c_proc( libui, "uiTabInsertAt", {C_POINTER,C_POINTER,C_UINT,C_POINTER} )
public procedure uiTabInsertAt( atom t, sequence name, atom before, atom c )
	c_proc( "uiTabInsertAt", {t,allocate_string(name,1),before,c} )
end procedure

define_c_proc( libui, "uiTabDelete", {C_POINTER,C_UINT} )
public procedure uiTabDelete( atom t, atom index )
	c_proc( "uiTabDelete", {t,index} )
end procedure

define_c_func( libui, "uiTabNumPages", {C_POINTER}, C_UINT )
public function uiTabNumPages( atom t )
	return c_func( "uiTabNumPages", {t} )
end function

define_c_func( libui, "uiTabMargined", {C_POINTER}, C_UINT )
public function uiTabMargined( atom t, atom page )
	return c_func( "uiTabMargined", {t,page} )
end function

define_c_proc( libui, "uiTabSetMargined", {C_POINTER,C_UINT,C_INT} )
public procedure uiTabSetMargined( atom t, atom page, atom margined )
	c_proc( "uiTabSetMargined", {t,page,margined} )
end procedure

define_c_func( libui, "uiNewTab", {}, C_POINTER )
public function uiNewTab()
	return c_func( "uiNewTab", {} )
end function



define_c_func( libui, "uiGroupTitle", {C_POINTER}, C_POINTER )
public function uiGroupTitle( atom g )
	atom ptr = c_func( "uiGroupTitle", {g} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiGroupSetTitle", {C_POINTER,C_POINTER} )
public procedure uiGroupSetTitle( atom g, sequence title )
	c_proc( "uiGroupSetTitle", {g,allocate_string(title,1)} )
end procedure

define_c_proc( libui, "uiGroupSetChild", {C_POINTER,C_POINTER} )
public procedure uiGroupSetChild( atom g, atom c )
	c_proc( "uiGroupSetChild", {g,c} )
end procedure

define_c_func( libui, "uiGroupMargined", {C_POINTER}, C_INT )
public function uiGroupMargined( atom g )
	return c_func( "uiGroupMargined", {g} )
end function

define_c_proc( libui, "uiGroupSetMargined", {C_POINTER,C_INT} )
public procedure uiGroupSetMargined( atom g, atom margined )
	c_proc( "uiGroupSetMargined", {g,margined} )
end procedure

define_c_func( libui, "uiNewGroup", {C_POINTER}, C_POINTER )
public function uiNewGroup( sequence title )
	return c_func( "uiNewGroup", {allocate_string(title,1)} )
end function



define_c_func( libui, "uiSpinboxValue", {C_POINTER}, C_INT )
public function uiSpinboxValue( atom s )
	return c_func( "uiSpinboxValue", {s} )
end function

define_c_proc( libui, "uiSpinboxSetValue", {C_POINTER,C_INT} )
public procedure uiSpinboxSetValue( atom s, atom value )
	c_proc( "uiSpinboxSetValue", {s,value} )
end procedure

define_c_proc( libui, "uiSpinboxOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiSpinboxOnChanged( atom s, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiSpinboxOnChanged", {s,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewSpinbox", {C_INT,C_INT}, C_POINTER )
public function uiNewSpinbox( atom min, atom max )
	return c_func( "uiNewSpinbox", {min,max} )
end function



define_c_func( libui, "uiSliderValue", {C_POINTER}, C_INT )
public function uiSliderValue( atom s )
	return c_func( "uiSliderValue", {s} )
end function

define_c_proc( libui, "uiSliderSetValue", {C_POINTER,C_INT} )
public procedure uiSliderSetValue( atom s, atom value )
	c_proc( "uiSliderSetValue", {s,value} )
end procedure

define_c_proc( libui, "uiSliderOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiSliderOnChanged( atom s, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiSliderOnChanged", {s,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewSlider", {C_INT,C_INT}, C_POINTER )
public function uiNewSlider( atom min, atom max )
	return c_func( "uiNewSlider", {min,max} )
end function



-- TODO implement uiProgressBarValue

--define_c_func( libui, "uiProgressBarValue", {C_POINTER}, C_INT )
--public function uiProgressBarValue( atom p )
--	return c_func( "uiProgressBarValue", {p} )
--end function

define_c_proc( libui, "uiProgressBarSetValue", {C_POINTER,C_INT} )
public procedure uiProgressBarSetValue( atom p, atom n )
	c_proc( "uiProgressBarSetValue", {p,n} )
end procedure

define_c_func( libui, "uiNewProgressBar", {}, C_POINTER )
public function uiNewProgressBar()
	return c_func( "uiNewProgressBar", {} )
end function



define_c_func( libui, "uiNewHorizontalSeparator", {}, C_POINTER )
public function uiNewHorizontalSeparator()
	return c_func( "uiNewHorizontalSeparator", {} )
end function



define_c_proc( libui, "uiComboboxAppend", {C_POINTER,C_POINTER} )
public procedure uiComboboxAppend( atom c, sequence text )
	c_proc( "uiComboboxAppend", {c,allocate_string(text,1)} )
end procedure

define_c_func( libui, "uiComboboxSelected", {C_POINTER}, C_INT )
public function uiComboboxSelected( atom c )
	return c_func( "uiComboboxSelected", {c} )
end function

define_c_proc( libui, "uiComboboxSetSelected", {C_POINTER,C_INT} )
public procedure uiComboboxSetSelected( atom c, atom n )
	c_proc( "uiComboboxSetSelected", {c,n} )
end procedure

define_c_proc( libui, "uiComboboxOnSelected", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiComboboxOnSelected( atom c, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiComboboxOnSelected", {c,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewCombobox", {}, C_POINTER )
public function uiNewCombobox()
	return c_func( "uiNewCombobox", {} )
end function



define_c_proc( libui, "uiEditableComboboxAppend", {C_POINTER,C_POINTER} )
public procedure uiEditableComboboxAppend( atom c, sequence text )
	c_proc( "uiEditableComboboxAppend", {c,allocate_string(text,1)} )
end procedure

define_c_func( libui, "uiEditableComboboxText", {C_POINTER}, C_POINTER )
public function uiEditableComboboxText( atom c )
	atom ptr = c_func( "uiEditableComboboxText", {c} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiEditableComboboxSetText", {C_POINTER,C_POINTER} )
public procedure uiEditableComboboxSetText( atom c, sequence text )
	c_proc( "uiEditableComboboxSetText", {c,allocate_string(text,1)} )
end procedure

-- TODO what do we call a function that sets the currently selected item and fills the
-- text field with it? editable comboboxes have no consistent concept of selected item

define_c_proc( libui, "uiEditableComboboxOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiEditableComboboxOnChanged( atom c, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiEditableComboboxOnChanged", {c,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewEditableCombobox", {}, C_POINTER )
public function uiNewEditableCombobox()
	return c_func( "uiNewEditableCombobox", {} )
end function



define_c_proc( libui, "uiRadioButtonsAppend", {C_POINTER,C_POINTER} )
public procedure uiRadioButtonsAppend( atom r, sequence text )
	c_proc( "uiRadioButtonsAppend", {r,allocate_string(text,1)} )
end procedure

define_c_func( libui, "uiRadioButtonsSelected", {C_POINTER}, C_INT )
public function uiRadioButtonsSelected( atom r )
	return c_func( "uiRadioButtonsSelected", {r} )
end function

define_c_proc( libui, "uiRadioButtonsSetSelected", {C_POINTER,C_INT} )
public procedure uiRadioButtonsSetSelected( atom r, atom n )
	c_proc( "uiRadioButtonsSetSelected", {r,n} )
end procedure

define_c_proc( libui, "uiRadioButtonsOnSelected", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiRadioButtonsOnSelected( atom r, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiRadioButtonsOnSelected", {r,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewRadioButtons", {}, C_POINTER )
public function uiNewRadioButtons()
	return c_func( "uiNewRadioButtons", {} )
end function



define_c_func( libui, "uiNewDateTimePicker", {}, C_POINTER )
public function uiNewDateTimePicker()
	return c_func( "uiNewDateTimePicker", {} )
end function

define_c_func( libui, "uiNewDatePicker", {}, C_POINTER )
public function uiNewDatePicker()
	return c_func( "uiNewDatePicker", {} )
end function

define_c_func( libui, "uiNewTimePicker", {}, C_POINTER )
public function uiNewTimePicker()
	return c_func( "uiNewTimePicker", {} )
end function



-- TODO provide a facility for entering tab stops?

define_c_func( libui, "uiMultilineEntryText", {C_POINTER}, C_POINTER )
public function uiMultilineEntryText( atom e )
	atom ptr = c_func( "uiMultilineEntryText", {C_POINTER} )
	if ptr then
		sequence str = peek_string( ptr )
		uiFreeText( ptr )
		return str
	end if
	return ""
end function

define_c_proc( libui, "uiMultilineEntrySetText", {C_POINTER,C_POINTER} )
public procedure uiMultilineEntrySetText( atom e, sequence text )
	c_proc( "uiMultilineEntrySetText", {e,allocate_string(text,1)} )
end procedure

define_c_proc( libui, "uiMultilineEntryAppend", {C_POINTER,C_POINTER} )
public procedure uiMultilineEntryAppend( atom e, sequence text )
	c_proc( "uiMultilineEntryAppend", {e,allocate_string(text,1)} )
end procedure

define_c_proc( libui, "uiMultilineEntryOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiMultilineEntryOnChanged( atom e, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiMultilineEntryOnChanged", {e,call_back(id),data} )
end procedure

define_c_func( libui, "uiMultilineEntryReadOnly", {C_POINTER}, C_INT )
public function uiMultilineEntryReadOnly( atom e )
	return c_func( "uiMultilineEntryReadOnly", {e} )
end function

define_c_proc( libui, "uiMultilineEntrySetReadOnly", {C_POINTER,C_INT} )
public procedure uiMultilineEntrySetReadOnly( atom e, atom readonly )
	c_proc( "uiMultilineEntrySetReadOnly", {e,readonly} )
end procedure

define_c_func( libui, "uiNewMultilineEntry", {}, C_POINTER )
public function uiNewMultilineEntry()
	return c_func( "uiNewMultilineEntry", {} )
end function

define_c_func( libui, "uiNewNonWrappingMultilineEntry", {}, C_POINTER )
public function uiNewNonWrappingMultilineEntry()
	return c_func( "uiNewNonWrappingMultilineEntry", {} )
end function


