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

	atom id = dll:define_c_func( lib, name, ptypes, rtype )
	if name[1] = '+' then name = name[2..$] end if

	map:put( id_lookup, name, id )

	return id
end function

function define_c_proc( atom lib, sequence name, sequence ptypes )

	atom id = dll:define_c_proc( lib, name, ptypes )
	if name[1] = '+' then name = name[2..$] end if

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
if libui = 0 then error:crash( "libui not found" ) end if



define_c_func( libui, "+uiInit", {C_POINTER}, C_POINTER )
public function uiInit( atom options = NULL )

	if options = NULL then
		options = allocate_data( sizeof(C_SIZE_T), 1 )
		poke4( options, NULL )
	end if

	object err = c_func( "uiInit", {options} )
	if err != NULL then

		sequence str = peek_string( err )
		c_proc( "uiFreeInitError", {err} )

		err = str

	end if

	return err
end function

define_c_proc( libui, "+uiUninit", {} )
public procedure uiUninit()
	c_proc( "uiUninit", {} )
end procedure

define_c_proc( libui, "+uiFreeInitError", {C_POINTER} )
public procedure uiFreeInitError( atom err )
	c_proc( "uiFreeInitError", {err} )
end procedure



define_c_proc( libui, "+uiMain", {} )
public procedure uiMain()
	c_proc( "uiMain", {} )
end procedure

define_c_func( libui, "+uiMainStep", {C_INT}, C_INT )
public function uiMainStep( atom wait )
	return c_func( "uiMainStep", wait )
end function

define_c_proc( libui, "+uiQuit", {} )
public procedure uiQuit()
	c_proc( "uiQuit", {} )
end procedure



define_c_proc( libui, "+uiQueueMain", {C_POINTER,C_POINTER} )
public procedure uiQueueMain( object func, atom data, atom id = routine_id(func) )
	c_proc( "uiQueueMain", {call_back(id),data} )
end procedure

define_c_proc( libui, "+uiOnShouldQuit", {C_POINTER,C_POINTER} )
public procedure uiOnShouldQuit( object func, atom data, atom id = routine_id(func) )
	c_proc( "uiOnShouldQuit", {call_back(id),data} )
end procedure

define_c_proc( libui, "uiFreeText", {C_POINTER} )
public procedure uiFreeText( atom text )
	c_proc( "uiFreeText", {text} )
end procedure



define_c_proc( libui, "+uiControlDestroy", {C_POINTER} )
public procedure uiControlDestroy( atom control )
	c_proc( "uiControlDestroy", {control} )
end procedure

define_c_proc( libui, "+uiControlShow", {C_POINTER} )
public procedure uiControlShow( atom control )
	c_proc( "uiControlShow", {control} )
end procedure



define_c_proc( libui, "+uiWindowOnClosing", {C_POINTER,C_POINTER,C_POINTER} )
public procedure uiWindowOnClosing( atom window, object func, atom data, atom id = routine_id(func) )
	c_proc( "uiWindowOnClosing", {window,call_back(id),data} )
end procedure

define_c_proc( libui, "+uiWindowSetMargined", {C_POINTER,C_INT} )
public procedure uiWindowSetMargined( atom window, atom margined )
	c_proc( "uiWindowSetMargined", {window,margined} )
end procedure

define_c_func( libui, "+uiNewWindow", {C_POINTER,C_INT,C_INT,C_INT}, C_POINTER )
public function uiNewWindow( sequence title, atom width, atom height, atom hasMenubar )
	return c_func( "uiNewWindow", {allocate_string(title,1),width,height,hasMenubar} )
end function
