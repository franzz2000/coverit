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

seleccionaIdioma(A_Language)

gosub, CreaMenus
    
    Gui, pixel: -Caption -Resize +LastFound
    Gui, pixel:add, Slider, vpixelSize range1-20 ToolTipBottom, %pixelSize%
    Gui, pixel:add, Button, Default gBotonOK, Ok

gosub, OpenWindow
return

CreaMenus:
    if Handle := MenuGetHandle("MyMenu")
        Menu, MyMenu, DeleteAll
	Menu, MyMenu, Add, %txt_NuevoRecuadro%, OpenWindow
    Menu, MyMenu, Add, %txt_CerrarRecuadro%, CerrarRecuadro
    Menu, MyMenu, Add
    Menu, MyMenu, Add, %txt_CambiarColor%, CambiarColor
    Menu, MyMenu, Add, %txt_IntercambiaTransparencia%, IntercambiaTransparencia
    Menu, MyMenu, Add
    Menu, MyMenu, Add, %txt_Pixelar%, Pixelar
    Menu, MyMenu, Add, %txt_CambiarPixel%, changePixelSize
    Menu, MyMenu, Add
	Menu, MyMenu, Add, %txt_Salir%, SalirApp
    
    if Handle := MenuGetHandle("MyLang")
        Menu, MyLang, DeleteAll
    Menu, MyLang, Add, %txt_Espanol%, ChangeSpanish
    Menu, MyLang, Add, %txt_Aleman%, ChangeGerman
    Menu, MyLang, Add, %txt_Ingles%, ChangeEnglish
	
    Menu, tray, NoStandard
    Menu, tray, DeleteAll
    Menu, tray, add, %txt_NuevoRecuadro%, OpenWindow  ; Creates a new menu item.
	Menu, tray, add  ; Creates a separator line.
    Menu, tray, add, %txt_CambiarPixel%, changePixelSize ;Cambia el valor del pixelado
	Menu, tray, add  ; Creates a separator line.
    Menu, tray, add, %txt_Idioma%, :MyLang
    Menu, tray, add  ; Creates a separator line.
    Menu, tray, add, %txt_AcercaDe%, AcercaDe
    Menu, tray, add, %txt_Salir%, SalirApp ;Sale de la aplicación
	
    
    
return  

;Item seleccionad de un menú: A_ThisMenuItem
ChangeSpanish:
    seleccionaIdioma("0c0a")
    gosub, CreaMenus
return

ChangeGerman:
    seleccionaIdioma("0407")
    gosub, CreaMenus
return

ChangeEnglish:
    seleccionaIdioma("0409")
    gosub, CreaMenus
return


CerrarRecuadro:
    ;PostMessage, 0x112, 0xF060,,, A
    WinGetTitle, VentanaActiva, A
    Gui, %VentanaActiva%:Destroy
    fichero := file%VentanaActiva%
    IfExist, %fichero%
    FileDelete, %fichero%
return

CambiarColor:
    WinGetTitle, VentanaActiva, A
    KeyWait, LButton, D
    MouseGetPos X, Y 
    PixelGetColor Color, %X%, %Y%, RGB
    Gui, %VentanaActiva%:Color, %Color%
    GuiControl,%VentanaActiva%:, MyPicture
    Gui, %VentanaActiva%:+Resize
return

Pixelar:
    WinGetTitle, VentanaActiva, A
    Pixela(VentanaActiva)
return

IntercambiaTransparencia:
    WinGetTitle, VentanaActiva, A
    WinGet, Transparencia, Transparent, %VentanaActiva%
    OutputDebug, Transparencia de %VentanaActiva%: %Transparencia%
    if Transparencia != 150
        WinSet, Transparent, 150, %VentanaActiva%
    else
        WinSet, Transparent, Off, %VentanaActiva%
return

AcercaDe:
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

seleccionaIdioma(code) {
    global ;txt_NuevoRecuadro, txt_CerrarRecuadro, txt_CambiarColor, txt_IntercambiaTransparencia, txt_Pixelar, txt_CambiarPixel, txt_Salir, txt_Acercade
    
    OutputDebug, %code%
    Spanish = 040a,080a,0c0a,100a,140a,180a,1c0a,200a,240a,280a,2c0a,300a,340a,380a,3c0a,400a,440a,480a,4c0a,500a
    German = 0407,0807,0c07,1007,1407

    if code in %Spanish%
    {
        txt_NuevoRecuadro := "Nuevo recuadro"
        txt_CerrarRecuadro := "Cerrar recuadro"
        txt_CambiarColor := "Cambiar color"
        txt_IntercambiaTransparencia := "Intercambia transparencia"
        txt_Pixelar := "Pixelar"
        txt_CambiarPixel := "Cambiar tamaño de pixel"
        txt_Salir := "Salir"
        txt_Aleman := "Aleman"
        txt_Ingles := "Inglés"
        txt_Espanol := "Español"
        txt_Idioma := "Idioma"
        txt_AcercaDe := "Acerca de"
    } else {
        if code in %German% 
        {
                txt_NuevoRecuadro := "Neuer Kasten"
                txt_CerrarRecuadro := "Kasten schliesen"
                txt_CambiarColor := "Farbe ändern"
                txt_IntercambiaTransparencia := "Durchsichtigkeit ändern"
                txt_Pixelar := "Pixelieren"
                txt_CambiarPixel := "Pixel Größe ändern"
                txt_Salir := "Schließen"
                txt_Aleman := "Deutsch"
                txt_Ingles := "Englisch"
                txt_Espanol := "Spanisch"
                txt_Idioma := "Sprache"
                txt_AcercaDe := "Über"
        } else {
                txt_NuevoRecuadro := "New frame"
                txt_CerrarRecuadro := "Close frame"
                txt_CambiarColor := "Change color"
                txt_IntercambiaTransparencia := "Toggle transparency"
                txt_Pixelar := "Pixelate"
                txt_CambiarPixel := "Change pixel size"
                txt_Salir := "Exit"
                txt_Aleman := "German"
                txt_Ingles := "English"
                txt_Espanol := "Spanish"
                txt_Idioma := "Language"
                txt_AcercaDe := "About"
            }
        }
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