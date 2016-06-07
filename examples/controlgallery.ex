include libui/ui.e

atom mainwin

function onClosing( atom window, atom data )

	uiControlDestroy( mainwin )
	uiQuit()

	return 0
end function

procedure main()

	object err
	atom menu	-- uiMenu
	atom item	-- uiMenuItem
	atom box	-- uiBox
	atom hbox	-- uiBox
	atom group	-- uiGroup
	atom inner	-- uiBox
	atom inner2	-- uiBox
	atom _entry	-- uiEntry
	atom cbox	-- uiComboBox
	atom ecbox	-- uiEditableComboBox
	atom rb		-- uiRadioButtons
	atom tab	-- uiTab

	err = uiInit()
	if sequence( err ) then
		puts( 2, err )
		abort( 1 )
	end if

	mainwin = uiNewWindow( "libui Control Gallery", 640, 480, 1 )
	uiWindowSetMargined( mainwin, 1 )
	uiWindowOnClosing( mainwin, "onClosing" )

	box = uiNewVerticalBox()
	uiBoxSetPadded( box, 1 )
	uiWindowSetChild( mainwin, box )

	hbox = uiNewHorizontalBox()
	uiBoxSetPadded( hbox, 1 )
	uiBoxAppend( box, hbox, 1 )

	group = uiNewGroup( "Basic Controls" )
	uiGroupSetMargined( group, 1 )
	uiBoxAppend( hbox, group, 0 )

	inner = uiNewVerticalBox()
	uiBoxSetPadded( inner, 1 )
	uiGroupSetChild( group, inner )

	uiBoxAppend( inner, uiNewButton("Button"), 0 )
	uiBoxAppend( inner, uiNewCheckbox("Checkbox"), 0 )

	_entry = uiNewEntry()
	uiEntrySetText( _entry, "Entry" )
	uiBoxAppend( inner, _entry, 0 )
	uiBoxAppend( inner, uiNewLabel("Label"), 0 )

	uiBoxAppend( inner, uiNewHorizontalSeparator(), 0 )

	uiBoxAppend( inner, uiNewDatePicker(), 0 )
	uiBoxAppend( inner, uiNewTimePicker(), 0 )
	uiBoxAppend( inner, uiNewDateTimePicker(), 0 )

	uiControlShow( mainwin )
	uiMain()
	uiUninit()

end procedure

main()
