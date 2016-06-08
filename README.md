# libui-euphoria

[Euphoria](http://openeuphoria.org/index.wc) bindings for libui (https://github.com/andlabs/libui)

## Development Notes

### C Wrapper Style

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
