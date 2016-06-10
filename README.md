# libui-euphoria

[libui](https://github.com/andlabs/libui) bindings for [Euphoria](http://openeuphoria.org/index.wc)

## Status

- [x] Wrapper code is complete; new features will be added as they arrive in [libui](https://github.com/andlabs/libui)
- [ ] Waiting on the completion of [#25](https://github.com/andlabs/libui/issues/25) in order to consider the wrapper stable for release

## History

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

A keen observer might notice the seemingly unorthodox C wrapper code used in `ui.e`. What I've done here, is use a `map` to provide string lookups for function names instead of using constants. This is an experiment in providing a cleaner C library wrapper. The calls to `define_c_func/proc` look a lot more like [attributes](https://msdn.microsoft.com/en-us/library/z0w1kczw.aspx) used in C# or VB.NET. I have not compared this method to using constants, so I'm not sure if or by how much this might be slower.

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
