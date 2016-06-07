include libui/ui.e

atom mainwin

function onClosing( atom window, atom data )

	uiControlDestroy( mainwin )
	uiQuit()

	return 0
end function

function shouldQuit( atom data )

	uiControlDestroy( mainwin )

	return 1
end function

function openClicked( atom item, atom window, atom data )

	sequence filename = uiOpenFile( mainwin )
	if length( filename ) = 0 then

		uiMsgBoxError( mainwin, "No file selected", "Don't be alarmed!" )
		return 0

	end if

	uiMsgBox( mainwin, "File selected", filename )

	return 0
end function

function saveClicked( atom item, atom window, atom data )

	sequence filename = uiSaveFile( mainwin )
	if length( filename ) = 0 then

		uiMsgBoxError( mainwin, "No file selected", "Don't be alarmed!" )
		return 0

	end if

	uiMsgBox( mainwin, "File selected (don't worry, it's still there)", filename )

	return 0
end function

atom spinbox
atom slider
atom progressbar

procedure update( atom value )

	uiSpinboxSetValue( spinbox, value )
	uiSliderSetValue( slider, value )
	uiProgressBarSetValue( progressbar, value )

end procedure

function onSpinboxChanged( atom s, atom data )

	update( uiSpinboxValue(spinbox) )

	return 0
end function

function onSliderChanged( atom s, atom data )

	update( uiSliderValue(slider) )

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

	menu = uiNewMenu( "File" )
	item = uiMenuAppendItem( menu, "Open" )
	uiMenuItemOnClicked( item, "openClicked" )
	item = uiMenuAppendItem( menu, "Save" )
	uiMenuItemOnClicked( item, "saveClicked" )
	item = uiMenuAppendQuitItem( menu )
	uiOnShouldQuit( "shouldQuit" )

	menu = uiNewMenu( "Edit" )
	item = uiMenuAppendCheckItem( menu, "Checkable Item" )
	uiMenuAppendSeparator( menu )
	item = uiMenuAppendItem( menu, "Disabled Item" )
	uiMenuItemDisable( item )
	item = uiMenuAppendPreferencesItem( menu )

	menu = uiNewMenu( "Help" )
	item = uiMenuAppendItem( menu, "Help" )
	item = uiMenuAppendAboutItem( menu )

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
	uiBoxAppend( inner, uiNewFontButton(), 0 )
	uiBoxAppend( inner, uiNewColorButton(), 0 )

	inner2 = uiNewVerticalBox()
	uiBoxSetPadded( inner2, 1 )
	uiBoxAppend( hbox, inner2, 1 )

	group = uiNewGroup( "Numbers" )
	uiGroupSetMargined( group, 1 )
	uiBoxAppend( inner2, group, 0 )

	inner = uiNewVerticalBox()
	uiBoxSetPadded( inner, 1 )
	uiGroupSetChild( group, inner )

	spinbox = uiNewSpinbox( 0, 100 )
	uiSpinboxOnChanged( spinbox, "onSpinboxChanged" )
	uiBoxAppend( inner, spinbox, 0 )

	slider = uiNewSlider( 0, 100 )
	uiSliderOnChanged( slider, "onSliderChanged" )
	uiBoxAppend( inner, slider, 0 )

	progressbar = uiNewProgressBar()
	uiBoxAppend( inner, progressbar, 0 )

	group = uiNewGroup( "Lists" )
	uiGroupSetMargined( group, 1 )
	uiBoxAppend( inner2, group, 0 )

	inner = uiNewVerticalBox()
	uiBoxSetPadded( inner, 1 )
	uiGroupSetChild( group, inner )

	cbox = uiNewCombobox()
	uiComboboxAppend( cbox, "Combobox Item 1" )
	uiComboboxAppend( cbox, "Combobox Item 2" )
	uiComboboxAppend( cbox, "Combobox Item 3" )
	uiBoxAppend( inner, cbox, 0 )

	ecbox = uiNewEditableCombobox()
	uiEditableComboboxAppend( ecbox, "Editable Item 1" )
	uiEditableComboboxAppend( ecbox, "Editable Item 2" )
	uiEditableComboboxAppend( ecbox, "Editable Item 3" )
	uiBoxAppend( inner, ecbox, 0 )

	rb = uiNewRadioButtons()
	uiRadioButtonsAppend( rb, "Radio Button 1" )
	uiRadioButtonsAppend( rb, "Radio Button 2" )
	uiRadioButtonsAppend( rb, "Radio Button 3" )
	uiBoxAppend( inner, rb, 0 )

	tab = uiNewTab()
	uiTabAppend( tab, "Tab 1", uiNewHorizontalBox() )
	uiTabAppend( tab, "Tab 2", uiNewHorizontalBox() )
	uiTabAppend( tab, "Tab 3", uiNewHorizontalBox() )
	uiBoxAppend( inner2, tab, 1 )

	uiControlShow( mainwin )
	uiMain()
	uiUninit()

end procedure

main()
