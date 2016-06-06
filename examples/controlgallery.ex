include libui/ui.e

atom mainwin

function onClosing( atom window, atom data )

	uiControlDestroy( mainwin )
	uiQuit()

	return 0
end function

procedure main()

	object err = uiInit()
	if sequence( err ) then
		puts( 2, err )
		abort( 1 )
	end if

	mainwin = uiNewWindow( "libui Control Gallery", 640, 480, 1 )
	uiWindowSetMargined( mainwin, 1 )
	uiWindowOnClosing( mainwin, "onClosing", NULL )

	uiControlShow( mainwin )
	uiMain()
	uiUninit()

end procedure

main()
