-- Create barebones example #27
-- https://github.com/andlabs/libui/pull/27

include libui/ui.e

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

procedure main()

	object err
	atom menu
	atom item
	atom box
	atom _label

	err = uiInit()
	if sequence( err ) then
		puts( 2, err )
		abort( 1 )
	end if

	menu = uiNewMenu( "File" )
	item = uiMenuAppendItem( menu, "Item" )
	item = uiMenuAppendQuitItem( menu )
	uiOnShouldQuit( "shouldQuit" )

	mainwin = uiNewWindow( "Window", 640, 480, 1 )
	uiWindowSetMargined( mainwin, 1 )
	uiWindowOnClosing( mainwin, "onClosing" )

	box = uiNewVerticalBox()
	uiBoxSetPadded( box, 1 )
	uiWindowSetChild( mainwin, box )

	_label = uiNewLabel( "Hello, World!" )
	uiBoxAppend( box, _label, 0 )

	uiControlShow( mainwin )
	uiMain()
	uiUninit()

end procedure

main()
