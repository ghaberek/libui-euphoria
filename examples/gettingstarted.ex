-- Getting Started
-- https://github.com/andlabs/ui/wiki/Getting-Started

include libui/ui.e

atom name
atom greeting
atom mainwin

function onClosing( atom w, atom data )

	uiControlDestroy( w )
	uiQuit()

	return 0
end function

function shouldQuit( atom data )

	uiControlDestroy( mainwin )

	return 1
end function

function onClicked( atom b )

	sequence text = uiEntryText( name )
	uiLabelSetText( greeting, "Hello " & text & "!" )

	return 0
end function

procedure main()

	object err
	atom button
	atom box

	err = uiInit()
	if sequence( err ) then
		puts( 2, err )
		abort( 1 )
	end if

	name = uiNewEntry()

	button = uiNewButton( "Greet" )
	uiButtonOnClicked( button, "onClicked" )

	greeting = uiNewLabel( "" )

	box = uiNewVerticalBox()
	uiBoxAppend( box, uiNewLabel("Enter your name:"), 0 )
	uiBoxAppend( box, name, 0 )
	uiBoxAppend( box, button, 0 )
	uiBoxAppend( box, greeting, 0 )

	mainwin = uiNewWindow( "Hello", 200, 100, 0 )
	uiWindowOnClosing( mainwin, "onClosing" )
	uiWindowSetChild( mainwin, box )

	uiControlShow( mainwin )
	uiMain()
	uiUninit()

end procedure

main()
