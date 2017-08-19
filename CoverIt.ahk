#SingleInstance, Force
#Persistent

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x204, "WM_RBUTTONDOWN")
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x84, "WM_NCHITTEST")
OnMessage(0x83, "WM_NCCALCSIZE")
OnMessage(0x86, "WM_NCACTIVATE")


Array := Object()
VentanaActiva = 
ventana = 1
	
	Menu, MyMenu, Add, Nueva Ventana, OpenWindow
	Menu, MyMenu, Add, Cambiar color, MenuHandler 
	Menu, MyMenu, Add, Cerrar, MenuHandler
	
	Menu, tray, add  ; Creates a separator line.
    Menu, tray, add, Nueva ventana, OpenWindow  ; Creates a new menu item.
	gosub, OpenWindow
return  ; End of script's auto-execute section.

MenuHandler:
  If (A_ThisMenuItem == "Cerrar") {
	  PostMessage, 0x112, 0xF060,,, A	  
  } else if (A_ThisMenuItem == "Cambiar color") {
	    WinGetTitle, VentanaActiva, A
	
	
	    KeyWait, LButton, D
		MouseGetPos X, Y 
		PixelGetColor Color, %X%, %Y%, RGB
		Gui, %VentanaActiva%:Color, %Color%
	}
return

OpenWindow:
	ventana_txt := "" + ventana
	Gui, %ventana_txt%:New
	
	Gui, %ventana_txt%:-Caption +Resize +AlwaysOnTop +ToolWindow +Hwndgui_id +LabelPrueba%ventana_txt%
	Gui, %ventana_txt%:Color, Blue
	Gui, %ventana_txt%:Show, W100 H100, %ventana_txt%
	Array.Insert(gui_id)
	ventana := ventana + 1	
return

GuiSize:
    GuiControl, Move, Border, X0 Y0 W%A_GuiWidth% H%A_GuiHeight%
return

WM_RBUTTONDOWN()
{
	Menu, MyMenu, Show 
}

; Allow moving the GUI by dragging any point in its client area.
WM_LBUTTONDOWN()
{
    if A_Gui
        PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
}

; Sizes the client area to fill the entire window.
WM_NCCALCSIZE()
{
    if A_Gui
        return 0
}

; Prevents a border from being drawn when the window is activated.
WM_NCACTIVATE()
{
    if A_Gui
        return 1
}

WM_MOUSEMOVE()
{
	
}

WM_MOUSELEAVE()
{
	;ToolTip, Saliendo ventana
	OnMessage(0x200, "WM_MOUSEMOVE")
}

; Redefine where the sizing borders are.  This is necessary since
; returning 0 for WM_NCCALCSIZE effectively gives borders zero size.
WM_NCHITTEST(wParam, lParam)
{
    static border_size = 6
    
    if !A_Gui
        return
    
    WinGetPos, gX, gY, gW, gH
    
    x := lParam<<48>>48, y := lParam<<32>>48
    
    hit_left    := x <  gX+border_size
    hit_right   := x >= gX+gW-border_size
    hit_top     := y <  gY+border_size
    hit_bottom  := y >= gY+gH-border_size
    
    if hit_top
    {
        if hit_left
            return 0xD
        else if hit_right
            return 0xE
        else
            return 0xC
    }
    else if hit_bottom
    {
        if hit_left
            return 0x10
        else if hit_right
            return 0x11
        else
            return 0xF
    }
    else if hit_left
        return 0xA
    else if hit_right
        return 0xB
    
    ; else let default hit-testing be done
}

GuiClose:
ExitApp

Button+:
    gosub, OpenWindow
return

^!a::
  gosub, OpenWindow
return