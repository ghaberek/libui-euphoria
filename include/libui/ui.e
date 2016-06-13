include std/dll.e
include std/machine.e
include std/convert.e
include std/error.e
include std/map.e

export constant NULL = dll:NULL

ifdef EU4_0 then

--
-- sizeof() is not declared in Euphoria 4.0
--
function sizeof( atom ctype )
	return and_bits( ctype, #FF )
end function

--
-- poke_pointer() is not declared in Euphoria 4.0
--
procedure poke_pointer( atom ptr, object value )
	poke4( ptr, value )
end procedure

--
-- peek_pointer() is not declared in Euphoria 4.0
--
function peek_pointer( object ptr )
	return peek4u( ptr )
end function

end ifdef

--
-- peek one or more C doubles from memory
--
function peek_float64( object ptr )

	if atom( ptr ) then
		ptr = peek_float64({ ptr, 1 })
		return ptr[1]
	end if

	atom offset = 0
	sequence values = repeat( 0, ptr[2] )

	for i = 1 to ptr[2] do

		sequence bytes = peek({ ptr[1]+offset, sizeof(C_DOUBLE) })
		values[i] = float64_to_atom( bytes )
		offset += sizeof( C_DOUBLE )

	end for

	return values
end function

--
-- poke one or more C doubles into memory
--
procedure poke_float64( atom ptr, object value )

	if atom( value ) then value = {value} end if

	atom offset = 0
	for i = 1 to length( value ) do

		sequence bytes = atom_to_float64( value[i] )
		poke( ptr+offset, bytes )
		offset += sizeof( C_DOUBLE )

	end for

end procedure

map id_lookup = map:new()

--
-- provide string lookups of C functions
--

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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
		c_proc( "uiFreeText", {ptr} )

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



define_c_proc( libui, "uiMenuItemEnable", {C_POINTER} )
public procedure uiMenuItemEnable( atom m )
	c_proc( "uiMenuItemEnable", {m} )
end procedure

define_c_proc( libui, "uiMenuItemDisable", {C_POINTER} )
public procedure uiMenuItemDisable( atom m )
	c_proc( "uiMenuItemDisable", {m} )
end procedure

define_c_proc( libui, "uiMenuItemOnClicked", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiMenuItemOnClicked( atom m, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiMenuItemOnClicked", {m,call_back(id),data} )
end procedure

define_c_func( libui, "uiMenuItemChecked", {C_POINTER}, C_INT )
public function uiMenuItemChecked( atom m )
	return c_func( "uiMenuItemChecked", {m} )
end function

define_c_proc( libui, "uiMenuItemSetChecked", {C_POINTER,C_INT} )
public procedure uiMenuItemSetChecked( atom m, atom checked )
	c_proc( "uiMenuItemSetChecked", {m,checked} )
end procedure



define_c_func( libui, "uiMenuAppendItem", {C_POINTER,C_POINTER}, C_POINTER )
public function uiMenuAppendItem( atom m, sequence name )
	return c_func( "uiMenuAppendItem", {m,allocate_string(name)} )
end function

define_c_func( libui, "uiMenuAppendCheckItem", {C_POINTER,C_POINTER}, C_POINTER )
public function uiMenuAppendCheckItem( atom m, sequence name )
	return c_func( "uiMenuAppendCheckItem", {m,allocate_string(name)} )
end function

define_c_func( libui, "uiMenuAppendQuitItem", {C_POINTER}, C_POINTER )
public function uiMenuAppendQuitItem( atom m )
	return c_func( "uiMenuAppendQuitItem", {m} )
end function

define_c_func( libui, "uiMenuAppendPreferencesItem", {C_POINTER}, C_POINTER )
public function uiMenuAppendPreferencesItem( atom m )
	return c_func( "uiMenuAppendPreferencesItem", {m} )
end function

define_c_func( libui, "uiMenuAppendAboutItem", {C_POINTER}, C_POINTER )
public function uiMenuAppendAboutItem( atom m )
	return c_func( "uiMenuAppendAboutItem", {m} )
end function

define_c_proc( libui, "uiMenuAppendSeparator", {C_POINTER} )
public procedure uiMenuAppendSeparator( atom m )
	c_proc( "uiMenuAppendSeparator", {m} )
end procedure

define_c_func( libui, "uiNewMenu", {C_POINTER}, C_POINTER )
public function uiNewMenu( sequence name )
	return c_func( "uiNewMenu", {allocate_string(name,1)} )
end function



define_c_func( libui, "uiOpenFile", {C_POINTER}, C_POINTER )
public function uiOpenFile( atom parent )

	atom ptr = c_func( "uiOpenFile", {parent} )

	if ptr then

		sequence str = peek_string( ptr )
		c_proc( "uiFreeText", {ptr} )

		return str
	end if

	return ""
end function

define_c_func( libui, "uiSaveFile", {C_POINTER}, C_POINTER )
public function uiSaveFile( atom parent )

	atom ptr = c_func( "uiSaveFile", {parent} )

	if ptr then

		sequence str = peek_string( ptr )
		c_proc( "uiFreeText", {ptr} )

		return str
	end if

	return ""
end function

define_c_proc( libui, "uiMsgBox", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiMsgBox( atom parent, sequence title, sequence description )
	c_proc( "uiMsgBox", {parent,allocate_string(title,1),allocate_string(description,1)} )
end procedure

define_c_proc( libui, "uiMsgBoxError", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiMsgBoxError( atom parent, sequence title, sequence description )
	c_proc( "uiMsgBoxError", {parent,allocate_string(title,1),allocate_string(description,1)} )
end procedure



define_c_proc( libui, "uiAreaSetSize", {C_POINTER,C_INT,C_INT} )
public procedure uiAreaSetSize( atom a, atom width, atom height )
	c_proc( "uiAreaSetSize", {a,width,height} )
end procedure

define_c_proc( libui, "uiAreaQueueRedrawAll", {C_POINTER} )
public procedure uiAreaQueueRedrawAll( atom a )
	c_proc( "uiAreaQueueRedrawAll", {a} )
end procedure

define_c_proc( libui, "uiAreaScrollTo", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiAreaScrollTo( atom a, atom x, atom y, atom width, atom height )
	c_proc( "uiAreaScrollTo", {a,x,y,width,height} )
end procedure



ifdef BITS64 then

	constant
		uiAreaHandler_Draw			=  0, -- pointer
		uiAreaHandler_MouseEvent	=  8, -- pointer
		uiAreaHandler_MouseCrossed	= 16, -- pointer
		uiAreaHandler_DragBroken	= 24, -- pointer
		uiAreaHandler_KeyEvent		= 32, -- pointer
		SIZEOF_UIAREAHANDLER		= 40,
	$

elsedef

	constant
		uiAreaHandler_Draw			=  0, -- pointer
		uiAreaHandler_MouseEvent	=  4, -- pointer
		uiAreaHandler_MouseCrossed	=  8, -- pointer
		uiAreaHandler_DragBroken	= 12, -- pointer
		uiAreaHandler_KeyEvent		= 16, -- pointer
		SIZEOF_UIAREAHANDLER		= 20,
	$

end ifdef


public function uiNewAreaHandler()

	atom ptr = allocate_data( SIZEOF_UIAREAHANDLER, 1 )
	mem_set( ptr, NULL, SIZEOF_UIAREAHANDLER )

	return ptr
end function

public procedure uiAreaSetDrawHandler( atom ah, object func, atom id = routine_id(func) )
	poke_pointer( ah + uiAreaHandler_Draw, call_back(id) )
end procedure

public procedure uiAreaSetMouseEventHandler( atom ah, object func, atom id = routine_id(func) )
	poke_pointer( ah + uiAreaHandler_MouseEvent, call_back(id) )
end procedure

public procedure uiAreaSetMouseCrossedHandler( atom ah, object func, atom id = routine_id(func) )
	poke_pointer( ah + uiAreaHandler_MouseCrossed, call_back(id) )
end procedure

public procedure uiAreaSetDragBrokenHandler( atom ah, object func, atom id = routine_id(func) )
	poke_pointer( ah + uiAreaHandler_DragBroken, call_back(id) )
end procedure

public procedure uiAreaSetKeyEventHandler( atom ah, object func, atom id = routine_id(func) )
	poke_pointer( ah + uiAreaHandler_KeyEvent, call_back(id) )
end procedure



define_c_func( libui, "uiNewArea", {C_POINTER}, C_POINTER )
public function uiNewArea( atom ah )
	return c_func( "uiNewArea", {ah} )
end function

define_c_func( libui, "uiNewScrollingArea", {C_POINTER,C_INT,C_INT}, C_POINTER )
public function uiNewScrollingArea( atom ah, atom width, atom height )
	return c_func( "uiNewScrollingArea", {ah,width,height} )
end function



ifdef BITS64 then

	constant
		uiAreaDrawParams_Context	=  0, -- pointer
		uiAreaDrawParams_AreaWidth	=  8, -- double
		uiAreaDrawParams_AreaHeight	= 16, -- double
		uiAreaDrawParams_ClipX		= 24, -- double
		uiAreaDrawParams_ClipY		= 32, -- double
		uiAreaDrawParams_ClipWidth	= 40, -- double
		uiAreaDrawParams_ClipHeight	= 48, -- double
		SIZEOF_UIAREADRAPARAMS		= 56,
	$

elsedef

	constant
		uiAreaDrawParams_Context	=  0, -- pointer
		uiAreaDrawParams_AreaWidth	=  4, -- double
		uiAreaDrawParams_AreaHeight	= 12, -- double
		uiAreaDrawParams_ClipX		= 20, -- double
		uiAreaDrawParams_ClipY		= 28, -- double
		uiAreaDrawParams_ClipWidth	= 36, -- double
		uiAreaDrawParams_ClipHeight	= 44, -- double
		SIZEOF_UIAREADRAPARAMS		= 52,
	$

end ifdef


public function uiAreaDrawGetContext( atom ap )
	return peek_pointer( ap + uiAreaDrawParams_Context )
end function

public function uiAreaDrawGetWidth( atom ap )
	return peek_float64( ap + uiAreaDrawParams_AreaWidth )
end function

public function uiAreaDrawGetHeight( atom ap )
	return peek_float64( ap + uiAreaDrawParams_AreaHeight )
end function

public function uiAreaDrawGetClipX( atom ap )
	return peek_float64( ap + uiAreaDrawParams_ClipX )
end function

public function uiAreaDrawGetClipY( atom ap )
	return peek_float64( ap + uiAreaDrawParams_ClipY )
end function

public function uiAreaDrawGetClipWidth( atom ap )
	return peek_float64( ap + uiAreaDrawParams_ClipWidth )
end function

public function uiAreaDrawGetClipHeight( atom ap )
	return peek_float64( ap + uiAreaDrawParams_ClipHeight )
end function



public enum type uiDrawBrushType

	uiDrawBrushTypeSolid = 0,
	uiDrawBrushTypeLinearGradient,
	uiDrawBrushTypeRadialGradient,
	uiDrawBrushTypeImage

end type

public enum type uiDrawLineCap

	uiDrawLineCapFlat = 0,
	uiDrawLineCapRound,
	uiDrawLineCapSquare

end type

public enum type uiDrawLineJoin

	uiDrawLineJoinMiter = 0,
	uiDrawLineJoinRound,
	uiDrawLineJoinBevel

end type

-- this is the default for botoh cairo and Direct2D (in the latter case, from the C++ helper functions)
-- Core Graphics doesn't explicitly specify a default, but NSBezierPath allows you to choose one, and this is the initial value
-- so we're good to use it too!
public constant uiDrawDefaultMiterLimit = 10.0

public enum type uiDrawFillMode

	uiDrawFillModeWinding = 0,
	uiDrawFillModeAlternate

end type

constant
	uiDrawMatrix_M11	=  0, -- double
	uiDrawMatrix_M12	=  8, -- double
	uiDrawMatrix_M21	= 16, -- double
	uiDrawMatrix_M22	= 24, -- double
	uiDrawMatrix_M31	= 32, -- double
	uiDrawMatrix_M32	= 40, -- double
	SIZEOF_UIDRAWMATRIX	= 48,
$

public function uiDrawMatrixGetMatrix( atom dm )
	return peek_float64({ dm, 6 })
end function

ifdef BITS64 then

	constant
		uiDrawBrush_Type		=  0, -- int
		uiDrawBrush_R			=  4, -- double
		uiDrawBrush_G			= 12, -- double
		uiDrawBrush_B			= 20, -- double
		uiDrawBrush_A			= 28, -- double
		uiDrawBrush_X0			= 36, -- double
		uiDrawBrush_Y0			= 44, -- double
		uiDrawBrush_X1			= 52, -- double
		uiDrawBrush_Y1			= 60, -- double
		uiDrawBrush_OuterRadius	= 68, -- double
		uiDrawBrush_Stops		= 76, -- pointer
		uiDrawBrush_NumStops	= 84, -- size_t
		SIZEOF_UIDRAWBRUSH		= 92,
	$

elsedef

	constant
		uiDrawBrush_Type		=  0, -- int
		uiDrawBrush_R			=  4, -- double
		uiDrawBrush_G			= 12, -- double
		uiDrawBrush_B			= 20, -- double
		uiDrawBrush_A			= 28, -- double
		uiDrawBrush_X0			= 36, -- double
		uiDrawBrush_Y0			= 44, -- double
		uiDrawBrush_X1			= 52, -- double
		uiDrawBrush_Y1			= 60, -- double
		uiDrawBrush_OuterRadius	= 68, -- double
		uiDrawBrush_Stops		= 76, -- pointer
		uiDrawBrush_NumStops	= 80, -- size_t
		SIZEOF_UIDRAWBRUSH		= 84,
	$

end ifdef

procedure uiFreeDrawBrush( atom db )

	atom ptr = peek_pointer( db + uiDrawBrush_Stops )
	if ptr then free( ptr ) end if

end procedure

public function uiNewDrawBrush()

	atom db = allocate_data( SIZEOF_UIDRAWBRUSH )
	mem_set( db, NULL, SIZEOF_UIDRAWBRUSH )

	return delete_routine( db, routine_id("uiFreeDrawBrush") )
end function

public function uiDrawBrushGetType( atom db )
	return peek4s( db + uiDrawBrush_Type )
end function

public procedure uiDrawBrushSetType( atom db, atom brushType )
	poke4( db + uiDrawBrush_Type, brushType )
end procedure

public function uiDrawBrushGetColor( atom db )
	return {
		peek_float64( db + uiDrawBrush_R ),
		peek_float64( db + uiDrawBrush_G ),
		peek_float64( db + uiDrawBrush_B ),
		peek_float64( db + uiDrawBrush_A )
	}
end function

public procedure uiDrawBrushSetColor( atom db, atom r, atom g, atom b, atom a )

	poke_float64( db + uiDrawBrush_R, r )
	poke_float64( db + uiDrawBrush_G, g )
	poke_float64( db + uiDrawBrush_B, b )
	poke_float64( db + uiDrawBrush_A, a )

end procedure

public function uiDrawBrushGetRect( atom db )
	return {
		peek_float64( db + uiDrawBrush_X0 ),
		peek_float64( db + uiDrawBrush_Y0 ),
		peek_float64( db + uiDrawBrush_X1 ),
		peek_float64( db + uiDrawBrush_Y1 )
	}
end function

public procedure uiDrawBrushSetRect( atom db, atom x0, atom y0, atom x1, atom y1 )

	poke_float64( db + uiDrawBrush_X0, x0 )
	poke_float64( db + uiDrawBrush_Y0, y0 )
	poke_float64( db + uiDrawBrush_X1, x1 )
	poke_float64( db + uiDrawBrush_Y1, y1 )

end procedure

public function uiDrawBrushGetRadius( atom db )
	return peek_float64( db + uiDrawBrush_OuterRadius )
end function

public procedure uiDrawBrushSetRadius( atom db, atom radius )
	poke_float64( db + uiDrawBrush_OuterRadius, radius )
end procedure

public function uiDrawBrushGetStops( atom db )

	atom num = peek_pointer( db + uiDrawBrush_NumStops )
	atom ptr = peek_pointer( db + uiDrawBrush_Stops )

	if ptr then
		return peek_float64({ ptr, num })
	end if

	return {}
end function

public procedure uiDrawBrushSetStops( atom db, sequence stops )

	atom ptr = peek_pointer( db + uiDrawBrush_Stops )
	atom num = length( stops )

	if ptr then
		free( ptr )
	end if

	if num then
		ptr = allocate_data( sizeof(C_DOUBLE)*num )
		poke_float64( ptr, stops )
	else
		ptr = NULL
	end if

	poke_pointer( db + uiDrawBrush_NumStops, num )
	poke_pointer( db + uiDrawBrush_Stops, ptr )

end procedure



constant
	uiDrawBrushGradientStop_Pos		=  0, -- double
	uiDrawBrushGradientStop_R		=  8, -- double
	uiDrawBrushGradientStop_G		= 16, -- double
	uiDrawBrushGradientStop_B		= 24, -- double
	uiDrawBrushGradientStop_A		= 32, -- double
	SIZE_UIDRAWBRUSHGRADIENTSTOP	= 40,
$

public function uiDrawBrushGradientStopGetPos( atom bg )
	return peek_float64( bg + uiDrawBrushGradientStop_Pos )
end function

public procedure uiDrawBrushGradientStopSetPos( atom bg, atom pos )
	poke_float64( bg + uiDrawBrushGradientStop_Pos, pos )
end procedure

public function uiDrawBrushGradientStopGetColor( atom bg )
	return {
		peek_float64( bg + uiDrawBrushGradientStop_R ),
		peek_float64( bg + uiDrawBrushGradientStop_G ),
		peek_float64( bg + uiDrawBrushGradientStop_B ),
		peek_float64( bg + uiDrawBrushGradientStop_A )
	}
end function

public procedure uiDrawBrushGradientStopSetColor( atom bg, atom r, atom g, atom b, atom a )

	poke_float64( bg + uiDrawBrushGradientStop_R, r )
	poke_float64( bg + uiDrawBrushGradientStop_G, g )
	poke_float64( bg + uiDrawBrushGradientStop_B, b )
	poke_float64( bg + uiDrawBrushGradientStop_A, a )

end procedure



ifdef BITS64 then

	constant
		uiDrawStrokeParams_Cap			=  0, -- int
		uiDrawStrokeParams_Join			=  4, -- int
		uiDrawStrokeParams_Thickness	=  8, -- double
		uiDrawStrokeParams_MiterLimit	= 16, -- double
		uiDrawStrokeParams_Dashes		= 24, -- pointer
		uiDrawStrokeParams_NumDashes	= 32, -- size_t
		uiDrawStrokeParams_DashPhase	= 40, -- double
		SIZEOF_UIDRASTROKEPARAMS		= 48,
	$

elsedef

	constant
		uiDrawStrokeParams_Cap			=  0, -- int
		uiDrawStrokeParams_Join			=  4, -- int
		uiDrawStrokeParams_Thickness	=  8, -- double
		uiDrawStrokeParams_MiterLimit	= 16, -- double
		uiDrawStrokeParams_Dashes		= 24, -- pointer
		uiDrawStrokeParams_NumDashes	= 28, -- size_t
		uiDrawStrokeParams_DashPhase	= 32, -- double
		SIZEOF_UIDRASTROKEPARAMS		= 40,
	$

end ifdef

procedure uiFreeDrawStrokeParams( atom ds )

	atom ptr = peek_pointer( ds + uiDrawStrokeParams_Dashes )
	if ptr then free( ptr ) end if

end procedure

public function uiNewDrawStrokeParams()

	atom ds = allocate_data( SIZEOF_UIDRASTROKEPARAMS )
	mem_set( ds, NULL, SIZEOF_UIDRASTROKEPARAMS )

	return delete_routine( ds, routine_id("uiFreeDrawStrokeParams") )
end function

public function uiDrawStrokeGetCap( atom ds )
	return peek4s( ds + uiDrawStrokeParams_Cap )
end function

public procedure uiDrawStrokeSetCap( atom ds, atom cap )
	poke4( ds + uiDrawStrokeParams_Cap, cap )
end procedure

public function uiDrawStrokeGetJoin( atom ds )
	return peek4s( ds + uiDrawStrokeParams_Join )
end function

public procedure uiDrawStrokeSetJoin( atom ds, atom join )
	poke4( ds + uiDrawStrokeParams_Join, join )
end procedure

public function uiDrawStrokeGetThickness( atom ds )
	return peek_float64( ds + uiDrawStrokeParams_Thickness )
end function

public procedure uiDrawStrokeSetThickness( atom ds, atom thickness )
	poke_float64( ds + uiDrawStrokeParams_Thickness, thickness )
end procedure

public function uiDrawStrokeGetMiterLimit( atom ds )
	return peek_float64( ds + uiDrawStrokeParams_MiterLimit )
end function

public procedure uiDrawStrokeSetMiterLimit( atom ds, atom miterLimit )
	poke_float64( ds + uiDrawStrokeParams_MiterLimit, miterLimit )
end procedure

public function uiDrawStrokeGetDashes( atom ds )

	atom ptr = peek_pointer( ds + uiDrawStrokeParams_Dashes )
	atom num = peek_pointer( ds + uiDrawStrokeParams_NumDashes )

	if ptr then
		return peek_float64({ ptr, num })
	end if

	return {}
end function

public procedure uiDrawStrokeSetDashes( atom ds, sequence dashes )

	atom ptr = peek_pointer( ds + uiDrawStrokeParams_Dashes )
	atom num = length( dashes )

	if ptr then
		free( ptr )
	end if

	if num then
		ptr = allocate_data( sizeof(C_DOUBLE)*num )
		poke_float64( ptr, dashes )
	else
		ptr = NULL
	end if

	poke_pointer( ds + uiDrawStrokeParams_NumDashes, num )
	poke_pointer( ds + uiDrawStrokeParams_Dashes, ptr )

end procedure

public function uiDrawStrokeGetDashPhase( atom ds )
	return peek_float64( ds + uiDrawStrokeParams_DashPhase )
end function

public procedure uiDrawStrokeSetDashPhase( atom ds, atom dashPhase )
	poke_float64( ds + uiDrawStrokeParams_DashPhase, dashPhase )
end procedure



define_c_func( libui, "uiDrawNewPath", {C_INT}, C_POINTER )
public function uiDrawNewPath( atom fillMode )
	return c_func( "uiDrawNewPath", {fillMode} )
end function

define_c_proc( libui, "uiDrawFreePath", {C_POINTER} )
public procedure uiDrawFreePath( atom p )
	c_proc( "uiDrawFreePath", {p} )
end procedure

define_c_proc( libui, "uiDrawPathNewFigure", {C_POINTER,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawPathNewFigure( atom p, atom x, atom y )
	c_proc( "uiDrawPathNewFigure", {p,x,y} )
end procedure

define_c_proc( libui, "uiDrawPathNewFigureWithArc", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_INT} )
public procedure uiDrawPathNewFigureWithArc( atom p, atom xCenter, atom yCenter, atom radius, atom startAngle, atom sweep, atom negative )
	c_proc( "uiDrawPathNewFigureWithArc", {p,xCenter,yCenter,radius,startAngle,sweep,negative} )
end procedure

define_c_proc( libui, "uiDrawPathLineTo", {C_POINTER,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawPathLineTo( atom p, atom x, atom y )
	c_proc( "uiDrawPathLineTo", {p,x,y} )
end procedure



-- notes: angles are both relative to 0 and go counterclockwise
-- TODO is the initial line segment on cairo and OS X a proper join?
-- TODO what if sweep < 0?

define_c_proc( libui, "uiDrawPathArcTo", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_INT} )
public procedure uiDrawPathArcTo( atom p, atom xCenter, atom yCenter, atom radius, atom startAngle, atom sweep, atom negative )
	c_proc( "uiDrawPathArcTo", {p,xCenter,yCenter,radius,startAngle,sweep,negative} )
end procedure

define_c_proc( libui, "uiDrawPathBezierTo", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawPathBezierTo( atom p, atom c1x, atom c1y, atom c2x, atom c2y, atom endX, atom endY )
	c_proc( "uiDrawPathBezierTo", {p,c1x,c1y,c2x,c2y,endX,endY} )
end procedure



-- TODO quadratic bezier

define_c_proc( libui, "uiDrawPathCloseFigure", {C_POINTER} )
public procedure uiDrawPathCloseFigure( atom p )
	c_proc( "uiDrawPathCloseFigure", {p} )
end procedure



-- TODO effect of these when a figure is already started

define_c_proc( libui, "uiDrawPathAddRectangle", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawPathAddRectangle( atom p, atom x, atom y, atom width, atom height )
	c_proc( "uiDrawPathAddRectangle", {p,x,y,width,height} )
end procedure

define_c_proc( libui, "uiDrawPathEnd", {C_POINTER} )
public procedure uiDrawPathEnd( atom p )
	c_proc( "uiDrawPathEnd", {p} )
end procedure



define_c_proc( libui, "uiDrawStroke", {C_POINTER,C_POINTER,C_POINTER,C_POINTER} )
public procedure uiDrawStroke( atom c, atom path, atom b, atom p )
	c_proc( "uiDrawStroke", {c,path,b,p} )
end procedure

define_c_proc( libui, "uiDrawFill", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiDrawFill( atom c, atom path, atom b )
	c_proc( "uiDrawFill", {c,path,b} )
end procedure



-- TODO primitives:
-- - rounded rectangles
-- - elliptical arcs
-- - quadratic bezier curves



define_c_proc( libui, "uiDrawMatrixSetIdentity", {C_POINTER} )
public procedure uiDrawMatrixSetIdentity( atom m )
	c_proc( "uiDrawMatrixSetIdentity", {m} )
end procedure

define_c_proc( libui, "uiDrawMatrixTranslate", {C_POINTER,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawMatrixTranslate( atom m, atom x, atom y )
	c_proc( "uiDrawMatrixTranslate", {m,x,y} )
end procedure

define_c_proc( libui, "uiDrawMatrixScale", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawMatrixScale( atom m, atom xCenter, atom yCenter, atom x, atom y )
	c_proc( "uiDrawMatrixScale", {m,xCenter,yCenter,x,y} )
end procedure

define_c_proc( libui, "uiDrawMatrixRotate", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawMatrixRotate( atom m, atom x, atom y, atom amount )
	c_proc( "uiDrawMatrixRotate", {m,x,y,amount} )
end procedure

define_c_proc( libui, "uiDrawMatrixSkew", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawMatrixSkew( atom m, atom x, atom y, atom xamount, atom yamount )
	c_proc( "uiDrawMatrixSkew", {m,x,y,xamount,yamount} )
end procedure

define_c_proc( libui, "uiDrawMatrixMultiply", {C_POINTER,C_POINTER} )
public procedure uiDrawMatrixMultiply( atom dest, atom src )
	c_proc( "uiDrawMatrixMultiply", {dest,src} )
end procedure

define_c_func( libui, "uiDrawMatrixInvertible", {C_POINTER}, C_INT )
public function uiDrawMatrixInvertible( atom m )
	return c_func( "uiDrawMatrixInvertible", {m} )
end function

define_c_func( libui, "uiDrawMatrixInvert", {C_POINTER}, C_INT )
public function uiDrawMatrixInvert( atom m )
	return c_func( "uiDrawMatrixInvert", {m} )
end function

define_c_proc( libui, "uiDrawMatrixTransformPoint", {C_POINTER,C_POINTER,C_POINTER} )
public function uiDrawMatrixTransformPoint( atom m )

	atom ptr = allocate_data( sizeof(C_DOUBLE)*2, 1 )
	mem_set( ptr, NULL, sizeof(C_DOUBLE)*2 )

	atom x = ptr + sizeof(C_DOUBLE)*0
	atom y = ptr + sizeof(C_DOUBLE)*1

	c_proc( "uiDrawMatrixTransformPoint", {m,x,y} )

	return peek_float64({ ptr, 2 })
end function

define_c_proc( libui, "uiDrawMatrixTransformSize", {C_POINTER,C_POINTER,C_POINTER} )
public function uiDrawMatrixTransformSize( atom m )

	atom ptr = allocate_data( sizeof(C_DOUBLE)*2, 1 )
	mem_set( ptr, NULL, sizeof(C_DOUBLE)*2 )

	atom x = ptr + sizeof(C_DOUBLE)*0
	atom y = ptr + sizeof(C_DOUBLE)*1

	c_proc( "uiDrawMatrixTransformSize", {m,x,y} )

	return peek_float64({ ptr, 2 })
end function

define_c_proc( libui, "uiDrawTransform", {C_POINTER,C_POINTER} )
public procedure uiDrawTransform( atom c, atom m )
	c_proc( "uiDrawTransform", {c,m} )
end procedure

-- TODO add a uiDrawPathStrokeToFill() or something like that

define_c_proc( libui, "uiDrawClip", {C_POINTER,C_POINTER} )
public procedure uiDrawClip( atom c, atom path )
	c_proc( "uiDrawClip", {c,path} )
end procedure

define_c_proc( libui, "uiDrawSave", {C_POINTER} )
public procedure uiDrawSave( atom c )
	c_proc( "uiDrawSave", {c} )
end procedure

define_c_proc( libui, "uiDrawRestore", {C_POINTER} )
public procedure uiDrawRestore( atom c )
	c_proc( "uiDrawRestore", {c} )
end procedure

-- TODO manage the use of Text, Font, and TextFont, and of the uiDrawText prefix in general


--// TODO

define_c_func( libui, "uiDrawListFontFamilies", {}, C_POINTER )
define_c_func( libui, "uiDrawFontFamiliesNumFamilies", {C_POINTER}, C_UINT )
define_c_func( libui, "uiDrawFontFamiliesFamily", {C_POINTER,C_UINT}, C_POINTER )
define_c_proc( libui, "uiDrawFreeFontFamilies", {C_POINTER} )

public function uiDrawListFontFamilies()

	atom ff = c_func( "uiDrawListFontFamilies", {} )
	atom num = c_func( "uiDrawListFontFamilies", {ff} )

	sequence values = repeat( "", num )
	for n = 0 to num - 1 do

		atom str = c_func( "uiDrawFontFamiliesFamily", {ff,n} )

		values[n] = peek_string( str )
		c_proc( "uiFreeText", {str} )

	end for

	c_proc( "uiDrawFreeFontFamilies", {ff} )

	return values
end function

--// END TODO


public enum type uiDrawTextWeight

	uiDrawTextWeightThin = 0,
	uiDrawTextWeightUltraLight,
	uiDrawTextWeightLight,
	uiDrawTextWeightBook,
	uiDrawTextWeightNormal,
	uiDrawTextWeightMedium,
	uiDrawTextWeightSemiBold,
	uiDrawTextWeightBold,
	uiDrawTextWeightUtraBold,
	uiDrawTextWeightHeavy,
	uiDrawTextWeightUltraHeavy

end type

public enum type uiDrawTextItalic

	uiDrawTextItalicNormal = 0,
	uiDrawTextItalicOblique,
	uiDrawTextItalicItalic

end type

public enum type uiDrawTextStretch

	uiDrawTextStretchUltraCondensed = 0,
	uiDrawTextStretchExtraCondensed,
	uiDrawTextStretchCondensed,
	uiDrawTextStretchSemiCondensed,
	uiDrawTextStretchNormal,
	uiDrawTextStretchSemiExpanded,
	uiDrawTextStretchExpanded,
	uiDrawTextStretchExtraExpanded,
	uiDrawTextStretchUltraExpanded

end type

ifdef BITS64 then

	constant
		uiDrawTextFontDescriptor_Family		=  0, -- pointer
		uiDrawTextFontDescriptor_Size		=  8, -- double
		uiDrawTextFontDescriptor_Weight		= 16, -- int
		uiDrawTextFontDescriptor_Italic		= 20, -- int
		uiDrawTextFontDescriptor_Stretch	= 24, -- int
		SIZEOF_UIDRAWTEXTFONTDESCRIPTOR		= 28,
	$

elsedef

	constant
		uiDrawTextFontDescriptor_Family		=  0, -- pointer
		uiDrawTextFontDescriptor_Size		=  4, -- double
		uiDrawTextFontDescriptor_Weight		= 12, -- int
		uiDrawTextFontDescriptor_Italic		= 16, -- int
		uiDrawTextFontDescriptor_Stretch	= 20, -- int
		SIZEOF_UIDRAWTEXTFONTDESCRIPTOR		= 24,
	$

end ifdef

procedure uiFreeDrawTextFontDescriptor( atom fd )

	atom ptr = peek_pointer( fd + uiDrawTextFontDescriptor_Family )
	if ptr then free( ptr ) end if

end procedure

public function uiNewDrawTextFontDescriptor()

	atom fd = allocate_data( SIZEOF_UIDRAWTEXTFONTDESCRIPTOR, 1 )
	mem_set( fd, NULL, SIZEOF_UIDRAWTEXTFONTDESCRIPTOR )

	return delete_routine( fd, routine_id("uiFreeDrawTextFontDescriptor") )
end function

public function uiDrawTextFontDescriptorGetFamily( atom fd )
	atom ptr = peek_pointer( fd + uiDrawTextFontDescriptor_Family )
	return peek_string( ptr )
end function

public procedure uiDrawTextFontDescriptorSetFamily( atom fd, sequence family )

	atom ptr = peek_pointer( fd + uiDrawTextFontDescriptor_Family )
	if ptr then free( ptr ) end if

	ptr = allocate_string( family )
	poke_pointer( fd + uiDrawTextFontDescriptor_Family, ptr )

end procedure



constant
	uiDrawTextFontMetrics_Ascent				=  0, -- double
	uiDrawTextFontMetrics_Descent				=  8, -- double
	uiDrawTextFontMetrics_Leading				= 16, -- double
	uiDrawTextFontMetrics_UnderlinePos			= 24, -- double
	uiDrawTextFontMetrics_UnderlineThickness	= 32, -- double
	SIZEOF_UIDRAWTEXTFONTMETRICS				= 40,
$

public function uiNewDrawTextFontMetrics()

	atom fm = allocate_data( SIZEOF_UIDRAWTEXTFONTMETRICS, 1 )
	mem_set( fm, NULL, SIZEOF_UIDRAWTEXTFONTMETRICS )

	return fm
end function

public function uiDrawTextFontMetricsGetAscent( atom fm )
	return peek_float64( fm + uiDrawTextFontMetrics_Ascent )
end function

public procedure uiDrawTextFontMetricsSetAscent( atom fm, atom ascent )
	poke_float64( fm + uiDrawTextFontMetrics_Ascent, ascent )
end procedure

public function uiDrawTextFontMetricsGetDescent( atom fm )
	return peek_float64( fm + uiDrawTextFontMetrics_Descent )
end function

public procedure uiDrawTextFontMetricsSetDescent( atom fm, atom descent )
	poke_float64( fm + uiDrawTextFontMetrics_Descent, descent )
end procedure

public function uiDrawTextFontMetricsGetLeading( atom fm )
	return peek_float64( fm + uiDrawTextFontMetrics_Leading )
end function

public procedure uiDrawTextFontMetricsSetLeading( atom fm, atom leading )
	poke_float64( fm + uiDrawTextFontMetrics_Leading, leading )
end procedure

public function uiDrawTextFontMetricsGetUnderlinePos( atom fm )
	return peek_float64( fm + uiDrawTextFontMetrics_UnderlinePos )
end function

public procedure uiDrawTextFontMetricsSetUnderlinePos( atom fm, atom pos )
	poke_float64( fm + uiDrawTextFontMetrics_UnderlinePos, pos )
end procedure

public function uiDrawTextFontMetricsGetUnderlineThickness( atom fm )
	return peek_float64( fm + uiDrawTextFontMetrics_UnderlineThickness )
end function

public procedure uiDrawTextFontMetricsSetUnderlineThickness( atom fm, atom thickness )
	poke_float64( fm + uiDrawTextFontMetrics_UnderlineThickness, thickness )
end procedure



define_c_func( libui, "uiDrawLoadClosestFont", {C_POINTER}, C_POINTER )
public function uiDrawLoadClosestFont( atom desc )
	return c_func( "uiDrawLoadClosestFont", {desc} )
end function

define_c_proc( libui, "uiDrawFreeTextFont", {C_POINTER} )
public procedure uiDrawFreeTextFont( atom font )
	c_proc( "uiDrawFreeTextFont", {font} )
end procedure

define_c_func( libui, "uiDrawTextFontHandle", {C_POINTER}, C_POINTER )
public function uiDrawTextFontHandle( atom font )
	return c_func( "uiDrawTextFontHandle", {font} )
end function

define_c_proc( libui, "uiDrawTextFontDescribe", {C_POINTER,C_POINTER} )
public procedure uiDrawTextFontDescribe( atom font, atom desc )
	c_proc( "uiDrawTextFontDescribe", {font,desc} )
end procedure

-- TODO make copy with given attributes methods?
-- TODO yuck this name

define_c_proc( libui, "uiDrawTextFontGetMetrics", {C_POINTER,C_POINTER} )
public procedure uiDrawTextFontGetMetrics( atom font, atom metrics )
	c_proc( "uiDrawTextFontGetMetrics", {font,metrics} )
end procedure

-- TODO initial line spacing? and what about leading?

define_c_func( libui, "uiDrawNewTextLayout", {C_POINTER,C_POINTER,C_DOUBLE}, C_POINTER )
public function uiDrawNewTextLayout( sequence text, atom defaultFont, atom width )
	return c_func( "uiDrawNewTextLayout", {allocate_string(text,1),defaultFont,width} )
end function

define_c_proc( libui, "uiDrawFreeTextLayout", {C_POINTER} )
public procedure uiDrawFreeTextLayout( atom layout )
	c_proc( "uiDrawFreeTextLayout", {layout} )
end procedure

-- TODO get width

define_c_proc( libui, "uiDrawTextLayoutSetWidth", {C_POINTER,C_DOUBLE} )
public procedure uiDrawTextLayoutSetWidth( atom layout, atom width )
	c_proc( "uiDrawTextLayoutSetWidth", {layout,width} )
end procedure

define_c_proc( libui, "uiDrawTextLayoutExtents", {C_POINTER,C_POINTER,C_POINTER} )
public function uiDrawTextLayoutExtents( atom layout )

	atom ptr = allocate_data( sizeof(C_POINTER)*2, 1 )

	atom width  = ptr + sizeof(C_POINTER)*0
	atom height = ptr + sizeof(C_POINTER)*1

	c_proc( "uiDrawTextLayoutExtents", {layout,width,height} )

	return peek_float64({ ptr, 2 })
end function

-- and the attributes that you can set on a text layout

define_c_proc( libui, "uiDrawTextLayoutSetColor", {C_POINTER,C_INT,C_INT,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiDrawTextLayoutSetColor( atom layout, atom startChar, atom endChar, atom r, atom g, atom b, atom a )
	c_proc( "uiDrawTextLayoutSetColor", {layout,startChar,endChar,r,g,b,a} )
end procedure

define_c_proc( libui, "uiDrawText", {C_POINTER,C_DOUBLE,C_DOUBLE,C_POINTER} )
public procedure uiDrawText( atom c, atom x, atom y, atom layout )
	c_proc( "uiDrawText", {c,x,y,layout} )
end procedure



public enum type uiModifiers

	uiModifierCtrl	= #01, -- 1 << 0
	uiModifierAlt	= #02, -- 1 << 1
	uiModifierShift	= #04, -- 1 << 2
	uiModifierSuper	= #08  -- 1 << 3

end type



public enum type uiExtKey

	uiExtKeyEscape,
	uiExtKeyInsert,		-- equivalent to "Help" on Apple keyboards
	uiExtKeyDelete,
	uiExtKeyHome,
	uiExtKeyEnd,
	uiExtKeyPageUp,
	uiExtKeyPageDown,
	uiExtKeyUp,
	uiExtKeyDown,
	uiExtKeyLeft,
	uiExtKeyRight,
	uiExtKeyF1,			-- F1..F12 are guaranteed to be consecutive
	uiExtKeyF2,
	uiExtKeyF3,
	uiExtKeyF4,
	uiExtKeyF5,
	uiExtKeyF6,
	uiExtKeyF7,
	uiExtKeyF8,
	uiExtKeyF9,
	uiExtKeyF10,
	uiExtKeyF11,
	uiExtKeyF12,
	uiExtKeyN0,			-- numpad keys; independent of Num Lock state
	uiExtKeyN1,			-- N0..N9 are guaranteed to be consecutive
	uiExtKeyN2,
	uiExtKeyN3,
	uiExtKeyN4,
	uiExtKeyN5,
	uiExtKeyN6,
	uiExtKeyN7,
	uiExtKeyN8,
	uiExtKeyN9,
	uiExtKeyNDot,
	uiExtKeyNEnter,
	uiExtKeyNAdd,
	uiExtKeyNSubtract,
	uiExtKeyNMultiply,
	uiExtKeyNDivide

end type


-- TODO SetFont, mechanics

define_c_func( libui, "uiFontButtonFont", {C_POINTER}, C_POINTER )
public function uiFontButtonFont( atom b )
	return c_func( "uiFontButtonFont", {b} )
end function

define_c_proc( libui, "uiFontButtonOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiFontButtonOnChanged( atom b, object func, atom data = NULL, atom id = routine_id(data) )
	c_proc( "uiFontButtonOnChanged", {b,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewFontButton", {}, C_POINTER )
public function uiNewFontButton()
	return c_func( "uiNewFontButton", {} )
end function



define_c_proc( libui, "uiColorButtonColor", {C_POINTER,C_POINTER,C_POINTER,C_POINTER,C_POINTER} )
public function uiColorButtonColor( atom bt )

	atom rgba = allocate_data( sizeof(C_DOUBLE)*4, 1 )
	poke_float64( rgba, {0,0,0,0} )

	atom r = rgba + sizeof(C_DOUBLE)*0
	atom g = rgba + sizeof(C_DOUBLE)*1
	atom b = rgba + sizeof(C_DOUBLE)*2
	atom a = rgba + sizeof(C_DOUBLE)*3

	c_proc( "uiColorButtonColor", {bt,r,g,b,a} )

	return peek_float64({ rgba, 4 })
end function

define_c_proc( libui, "uiColorButtonSetColor", {C_POINTER,C_DOUBLE,C_DOUBLE,C_DOUBLE,C_DOUBLE} )
public procedure uiColorButtonSetColor( atom bt, atom r, atom g, atom b, atom a )
	c_proc( "uiColorButtonSetColor", {bt,r,g,b,a} )
end procedure

define_c_proc( libui, "uiColorButtonOnChanged", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiColorButtonOnChanged( atom bt, object func, atom data = NULL, atom id = routine_id(func) )
	c_proc( "uiColorButtonOnChanged", {bt,call_back(id),data} )
end procedure

define_c_func( libui, "uiNewColorButton", {}, C_POINTER )
public function uiNewColorButton()
	return c_func( "uiNewColorButton", {} )
end function



define_c_proc( libui, "uiFormAppend", {C_POINTER,C_POINTER,C_POINTER,C_INT} )
public procedure uiFormAppend( atom f, sequence _label, atom c, atom stretchy )
    c_proc( "uiFormAppend", {f,allocate_string(_label,1),c,stretchy} )
end procedure

define_c_func( libui, "uiFormPadded", {C_POINTER}, C_INT )
public procedure uiFormPadded( atom f )
    c_proc( "uiFormPadded", {f} )
end procedure

define_c_proc( libui, "uiFormSetPadded", {C_POINTER,C_INT} )
public procedure uiFormSetPadded( atom f, atom padded )
    c_proc( "uiFormSetPadded", {f,padded} )
end procedure

define_c_func( libui, "uiNewForm", {}, C_POINTER )
public function uiNewForm()
    return c_func( "uiNewForm", {} )
end function



public enum type uiAlign

	uiAlignFill = 0,
	uiAlignStart,
	uiAlignCenter,
	uiAlignEnd

end type

public enum type uiAt

	uiAtLeading = 0,
	uiAtTop,
	uiAtTrailing,
	uiAtBottom

end type

define_c_proc( libui, "uiGridAppend", {C_POINTER,C_POINTER,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT} )
public procedure uiGridAppend( atom g, atom c, atom left, atom top, atom xspan, atom yspan, atom hexpand, atom halign, atom vexpand, atom valign )
	c_proc( "uiGridAppend", {g,c,left,top,xspan,yspan,hexpand,halign,vexpand,valign} )
end procedure

define_c_proc( libui, "uiGridInsertAt", {C_POINTER,C_POINTER,C_POINTER,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT,C_INT} )
public procedure uiGridInsertAt( atom g, atom c, atom existing, atom at,atom left, atom top, atom xspan, atom yspan, atom hexpand, atom halign, atom vexpand, atom valign )
	c_proc( "uiGridInsertAt", {g,c,existing,at,left,top,xspan,yspan,hexpand,halign,vexpand,valign} )
end procedure

define_c_func( libui, "uiGridPadded", {C_POINTER}, C_INT )
public function uiGridPadded( atom g )
	return c_func( "uiGridPadded", {g} )
end function

define_c_proc( libui, "uiGridSetPadded", {C_POINTER,C_INT} )
public procedure uiGridSetPadded( atom g, atom padded )
	c_proc( "uiGridSetPadded", {g,padded} )
end procedure

define_c_func( libui, "uiNewGrid", {}, C_POINTER )
public function uiNewGrid()
	return c_func( "uiNewGrid", {} )
end function
