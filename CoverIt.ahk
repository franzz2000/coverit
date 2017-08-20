;IMPORTANTE Ejecutar como una aplicación de 32 bits, no funciona con 64bits
#SingleInstance, Force
#Persistent

#Include lib/Gdip.ahk

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x204, "WM_RBUTTONDOWN")
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x84, "WM_NCHITTEST")
OnMessage(0x83, "WM_NCCALCSIZE")
OnMessage(0x86, "WM_NCACTIVATE")

OnExit, SalirApp

;Array := Object()
VentanaActiva = 
ventana = 1
pixelSize = 5

;Selecciona un directorio para incluir las capturas de pantalla
Work_Dir = %temp%
SetWorkingDir, %Work_Dir%   
    IfNotExist Screenshots
    FileCreateDir, Screenshots

folder_path := A_WorkingDir . "\Screenshots\"
index :=2
	
    
	Menu, MyMenu, Add, Nuevo recuadro, OpenWindow
	Menu, MyMenu, Add, Cerrar recuadro, MenuHandler
    Menu, MyMenu, Add
    Menu, MyMenu, Add, Cambiar color, MenuHandler
    Menu, MyMenu, Add, Intercambia transparencia, MenuHandler
    Menu, MyMenu, Add
    Menu, MyMenu, Add, Pixelar, MenuHandler
    Menu, MyMenu, Add, Cambiar Tamaño de pixel, changePixelSize
    Menu, MyMenu, Add
	Menu, MyMenu, Add, Salir, MenuHandler
	
    Menu, tray, NoStandard
    Menu, tray, add, Nuevo recuadro, OpenWindow  ; Creates a new menu item.
	Menu, tray, add  ; Creates a separator line.
    Menu, tray, add, Cambiar tamaño de pixel, changePixelSize ;Cambia el valor del pixelado
	Menu, tray, add  ; Creates a separator line.
    Menu, tray, add, Salir, SalirApp ;Sale de la aplicación
	gosub, OpenWindow
    
    Gui, pixel: -Caption -Resize +LastFound
    Gui, pixel:add, Slider, vpixelSize range1-20 ToolTipBottom, %pixelSize%
    Gui, pixel:add, Button, Default gBotonOK, Ok
return  ; End of script's auto-execute section.

MenuHandler:
  WinGetTitle, VentanaActiva, A
  if (A_ThisMenuItem == "Salir") {
    gosub, SalirApp
  } else If (A_ThisMenuItem == "Cerrar recuadro") {
	  ;PostMessage, 0x112, 0xF060,,, A
      Gui, %VentanaActiva%:Destroy
      fichero := file%VentanaActiva%
      IfExist, %fichero%
        FileDelete, %fichero%
  } else If (A_ThisMenuItem == "Cambiar color") {
	    KeyWait, LButton, D
		MouseGetPos X, Y 
		PixelGetColor Color, %X%, %Y%, RGB
		Gui, %VentanaActiva%:Color, %Color%
        GuiControl,%VentanaActiva%:, MyPicture
        Gui, %VentanaActiva%:+Resize
	} else if (A_ThisMenuItem == "Pixelar") {
        Pixela(VentanaActiva)
    } else if (A_ThisMenuItem == "Intercambia transparencia") {
        WinGet, Transparencia, Transparent, %VentanaActiva%
        OutputDebug, Transparencia de %VentanaActiva%: %Transparencia%
        if Transparencia != 150
            WinSet, Transparent, 150, %VentanaActiva%
        else
            WinSet, Transparent, Off, %VentanaActiva%
    }
return

changePixelSize:
    WinGetTitle, VentanaActiva, A
    SysGet, Mon, MonitorWorkArea
    pixelSizeOld := pixelSize
    Gui, pixel:Show, 
    Gui, pixel:+LastFound
    hwnd := Winexist()
    if VentanaActiva
    {
        WinGetPos,ix,iy,w,h, %VentanaActiva%
        WinMove, ahk_id %hwnd%,,ix,iy+h
    } else {
        WinGetTitle, VentanaSlider, A
        WinGetPos,ix,iy,w,h, %VentanaSlider%
        OutputDebug, Ancho: %w% de %hwnd%
        WinMove, ahk_id %hwnd%,,MonRight-w,MonBottom-h
    }
return

BotonOk:
    Gui, pixel:Submit
    if VentanaActiva
        Pixela(VentanaActiva)
return

Pixela(VentanaActiva) {
    global folder_path
    WinGetPos, x1, y1, w1, h1, %VentanaActiva%
    
    Gui, %VentanaActiva%:Hide
    
    screen := x1 . "|" . y1 . "|" . w1 . "|" h1  ;  X|Y|W|H

    file%VentanaActiva% := folder_path  "screenshot " A_Now_Format(A_Now)  " " w1 "x" h1 ".png"

    file_GUI:=file%VentanaActiva%
    sleep 300
    Screenshot(file_GUI,screen)
    Gui, %VentanaActiva%: -Resize +ToolWindow +AlwaysOnTop
    GuiControl,%VentanaActiva%:, MyPicture,  %file_GUI%
    Gui,%VentanaActiva%: Show, NA
    WinSet, Transparent, Off, %VentanaActiva%
    hwnd%VentanaActiva% := WinExist()
}

OpenWindow:
	ventana_txt := "" + ventana
	Gui, %ventana_txt%:New
    Gui, %ventana_txt%: -Caption +Resize +LastFound +AlwaysOnTop +ToolWindow
	Gui, %ventana_txt%:Color, Blue
    Gui, %ventana_txt%:Add, Picture, vMyPicture x0 y0
	Gui, %ventana_txt%:Show, W100 H100, %ventana_txt%
    WinSet, Transparent, 150, %ventana_txt%
	ventana := ventana + 1	
return

WM_RBUTTONDOWN()
{
    If A_Gui is number
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

Screenshot(outfile, screen) {
    global pixelSize
    If !pToken := Gdip_Startup()
        {
           MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
           ExitApp
        }
        
    raster := 0x40000000 + 0x00CC0020

    pBitmap := Gdip_BitmapFromScreen(screen,raster)
    
    ; Get the width and height of the bitmap we have just created from the file
    Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

    ; We also need to create
    pBitmapOut := Gdip_CreateBitmap(Width, Height)    

    ; Call Gdip_PixelateBitmap with the bitmap we retrieved earlier and the block size of the pixels
    ; The function returns the pixelated bitmap, and doesn't dispose of the original bitmap
    Gdip_PixelateBitmap(pBitmap, pBitmapOut, pixelSize)

    Gdip_SaveBitmapToFile(pBitmapOut, outfile, 100)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}

A_Now_Format(raw){
   RegExMatch(raw,"^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})", d)
   date:=d1 "-" d2 "-" d3  " " d4 "-" d5 "-" d6
   return date
}

GuiClose:
    ExitApp
    
SalirApp:
  FileRemoveDir, %folder_path%, 1
  ExitApp

Button+:
    gosub, OpenWindow
return

^!a::
  gosub, OpenWindow
return