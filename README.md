# libui-euphoria

[libui](https://github.com/andlabs/libui) bindings for [Euphoria](http://openeuphoria.org/index.wc)

## Status

- [x] Wrapper code is complete; new features will be added as they arrive in [libui](https://github.com/andlabs/libui).
- [ ] Testing is incomplete. More examples are welcome.

This wrapper should be stable but keep in mind that [libui](https://github.com/andlabs/libui) is still in
 [alpha](https://github.com/andlabs/libui/blob/master/TODO.md) status.

## History

### February 22, 2018

* Added DEBUG output to define_c_func/proc
* Added `uiControlVerifySetParent()`
* Added `uiControlEnabledToUser()`
* Added `uiUserBugCannotSetParentOnToplevel()`
* Added blurb about position routines to comments
* Added test for `-1` in event handler assignment
* Removed missing `uiDraw` functions

### December 9, 2016

* Added new position functions
* Added more `uiDrawBrush` functions
* Removed old position functions

### June 17, 2016

* Added `uiFormDelete()`
* Added `uiProgressBarValue()`
* Added `uiMainSteps()`
* Added `uiNewVerticalSeparator()`
* Added window position functions
* Added window borderless functions
* Added window fullscreen functions
* Added Window content size functions

### June 13, 2016

* Added more examples
* Wrapped `uiGrid` control
* Changed `call_back()` lines to use CDECL
* Fixed memory allocation in `uiDrawTextLayoutExtents`

### June 9, 2016

* Wrapped more draw functions
* Wrapped new `uiForm` control

### June 8, 2016

* Wrapped more draw functions

### June 7, 2016

* Wrapped more controls
* Wrapped draw functions
* Changed string functions to call `uiFreeText()`
* Completed `controlgallery.ex` example

### June 6, 2016

* Initial commit
* Wrapped most controls
* Created `controlgallery.ex` example

## Notes

### Wrapper Style

A keen observer might notice the seemingly unorthodox C wrapper code used in `ui.e`. What I've done here, is use a `map`
 to provide string lookups for function names instead of using constants. This is an experiment in providing a cleaner
 C library wrapper. The calls to `define_c_func/proc` look a lot more like [attributes](https://msdn.microsoft.com/en-us/library/z0w1kczw.aspx)
 used in C# or VB.NET. I have not compared this method to using constants, so I'm not sure if or by how much this might
 be slower.

#### Original Code

    constant _uiNewWindow = define_c_func( libui, "uiNewWindow", {C_POINTER,C_INT,C_INT,C_INT}, C_POINTER )
    public function uiNewWindow( sequence title, atom width, atom height, atom hasMenubar )
        return c_func( _uiNewWindow, {allocate_string(title,1),width,height,hasMenubar} )
    end function

#### Wrapper Code

    define_c_func( libui, "uiNewWindow", {C_POINTER,C_INT,C_INT,C_INT}, C_POINTER )
    public function uiNewWindow( sequence title, atom width, atom height, atom hasMenubar )
        return c_func( "uiNewWindow", {allocate_string(title,1),width,height,hasMenubar} )
    end function
