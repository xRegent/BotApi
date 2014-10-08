;;;
;;; BotApi - API для создания графических роботов на языке autoit
;;;
;;; @home:    http://l-i-v-e.ru/
;;; @autor:   Aleks Regent
	$version = 0.2
;;;

;;;
;;; CPS - COORDINATES with PixelSum
;;;     - формат массива из 3-х элементов,
;;;       Первые два элемента - координаты X и Y относительно рабочей области окна
;;;       Третий элемент массива - контрольная сумма пикселей площадью 9*3 с центром в координатах X и Y
;;;
#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
Opt( "CaretCoordMode", 2 )
Opt( "MouseCoordMode", 2 )
Opt( "PixelCoordMode", 2 )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VARS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global $_w, $_wPos, $_gui, $_guiPos, $_isLogicCircle = 0, $_counter = 0, $_X = 0, $_Y = 0
$_windowName = "[ACTIVE]"                        ; Имя окна. Например "ProgramTopTitle" или "[CLASS:ProgClassName]"
$_windowPath = ""                                ; Путь до приложения, которое нужно запустить в случае, если оно не запущено
$_botName = 'BotApi ' & $version
; Moves
$_move                     = 1                   ; Перемещать окно и изменять его размеры при старте?
Dim $_moveSize[ 2 ]        = [ 1600, 900 ]       ; Новые размеры окна, например 16*9: 1280 x 720, 1366 x 768, 1536 x 864, 1600 x 900, 1920 x 1080
Dim $_movePos[ 2 ]         = [ _                 ; Новая позиция окна(X,Y)
	@DesktopWidth  / 2 - $_moveSize[ 0 ] / 2, _  ; X
	0  _                                         ; Y
]
; MOUSE
Dim $_mouseDefaultPos[ 2 ] = [ 10, 10 ]          ; Позиция мыши по умолчанию относительно окна программы
$_mouseSpeed               = 0                   ; Скорость движения мыши при клике (0-10)
$_mouseSpeedToDefaultPos   = 0                   ; Скорость движения мыши на позицию по умолчанию
$_mouseClicksAmount        = 5                   ; Количество кликов при одном клике по умолчанию
$_sleepBeforeClick         = 10                  ; Ждать до клика MS
$_sleepAfterClick          = 10                  ; Ждать после клика MS
; Buttons
$_btnExit                  = "{ESC}"             ; Кнопка выключения приложения
$_btnStart                 = "{F1}"              ; Запуск приложения
$_btnStop                  = "{F2}"              ; Остановка приложения
$_btnGetPos                = "{F3}"              ; Получить координаты курсора
$_btnGetCPS                = "{F4}"              ; Получить CPS
; Задержки
$_sleepBeforeStart         = 500                 ; Задержка перед стартом движка
$_sleepInCircle            = 500                 ; Задержка в цикле
; GUI
$_is_GUI                   = 1
$_is_GUI_btn_close         = 1
$_is_GUI_btn_getPos        = 1
$_is_GUI_btn_getCPS        = 1
$_is_GUI_icon              = 1
$_is_GUI_console           = 1
$_gui_icon                 = @ScriptDir & "\assets\logo64x64.gif"
; COS DATA
Dim $CPS_STACK[ 0 ]        = []                  ; Хранилище CPS-массивов
Dim $_General[ 1 ][ 3 ]    = [[0,0,0]]           ; Главный CPS-массив логики
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Завершить приложение
HotKeySet( $_btnExit, "_Exit" )
Func _Exit()
	Exit
EndFunc

; Запустить бесконечный цикл обработки данных
HotKeySet( $_btnStart, "_Start" )
Func _Start()
	$_isLogicCircle = 1
	_log( 'Start' )
EndFunc
; Остановить бесконечный цикл
HotKeySet( $_btnStop, "_Stop" )
Func _Stop()
	_log( 'Stop' )
	$_isLogicCircle = 0
EndFunc

; Получить текущую позицию курсора
HotKeySet( $_btnGetPos, "_logPos" )
func getPos()
	WinActivate( $_w )
	return MouseGetPos()
endfunc
func _logPos()
	local $pos = getPos()
	return _log( '[ ' & $pos[ 0 ] & ', ' & $pos[ 1 ] & ' ]' )
endfunc

; Получить массив формата CPS
HotKeySet( $_btnGetCPS, "_logCPS" )
Func getCPS( $x = 0.1, $y = 0.1 )

	if $x = 0.1 then
		dim $pos = getPos()
		$x = $pos[ 0 ]
		$y = $pos[ 1 ]
	endif

	GoDefaultPos()
	sleep( 100 )

	local $square[ 4 ] = [ $x - 4, $y - 1, $x + 4, $y + 1 ]
	local $sum = PixelChecksum( $square[ 0 ], $square[ 1 ], $square[ 2 ], $square[ 3 ] )

	MouseMove( $square[ 0 ], $square[ 1 ], 10 )
	sleep( 300 )
	MouseMove( $square[ 2 ], $square[ 3 ], 10 )
	sleep( 10 )

	return '[' & $x & ',' & $y & ',' & $sum & ']'
EndFunc
Func _logCPS()
	return _log( getCPS(), 1 );
EndFunc

; Поставить мышь в позицию по умолчанию
func GoDefaultPos( $speed = -1 )
	if $speed = -1 then $speed = $_mouseSpeedToDefaultPos
	return MouseMove( $_mouseDefaultPos[ 0 ], $_mouseDefaultPos[ 1 ], $speed )
endfunc

; Системный диалог
func alert( $mess, $type = 0 )
	MsgBox( $type, '', $mess )
endfunc

; Копировать в буфер обмена
func copy( $mess )
	Clipput( $mess )
endfunc

; Отправить сообщение в консоль
func _log( $mess, $isCopy = 0 )
	if $isCopy then copy( $mess )
	ConsoleWrite( '* ' & _NowTime() & ' |- ' & $mess & @LF )

	if IsDeclared( '_gui_console' ) then
		GUICtrlSetData( $_gui_console, @CRLF & $mess, 1 )
	endif
	if IsDeclared( '_gui_console_time' ) then
		GUICtrlSetData( $_gui_console_time, @CRLF & _NowTime(), 1 )
	endif

endfunc

; Проверка на наличие CPS на дисплее
func isCPS( $CPSmultiArray, $CPS_index )
	local $pix = PixelChecksum( _
		$CPSmultiArray[ $CPS_index ][0] - 4, _
		$CPSmultiArray[ $CPS_index ][1] - 1, _
		$CPSmultiArray[ $CPS_index ][0] + 4, _
		$CPSmultiArray[ $CPS_index ][1] + 1  _
	)
	return $pix = $CPSmultiArray[ $CPS_index ][ 2 ]
endfunc

; Получить массив с индексом $index из многомерного массива $multiArray
func GetArray( $multiArray, $index )
	local $len = UBound( $multiArray, 2 )
	local $newArr[ $len ]
	for $i = 0 to $len -1 step 1
		$newArr[ $i ] = $multiArray[ $index ][ $i ]
	next
	return $newArr
endfunc

; Клик по CPS на дисплее
func clickCPS( $CPSmultiArray, $CPS_index )
	return click( $CPSmultiArray[ $CPS_index ][ 0 ], $CPSmultiArray[ $CPS_index ][ 1 ] )
endfunc

; Клик по реальным X и Y на дисплее
func click( $x = 0.1, $y = 0.1 )
WinActivate( $_w )
	if $x = 0.1 then
		$x = $_X
		$y = $_Y
	endif
	sleep( $_sleepBeforeClick )
	MouseClick( '', $x, $y, $_mouseClicksAmount, $_mouseSpeed )
	GoDefaultPos()
	sleep( $_sleepAfterClick )
	return 1
endfunc



func _minuts( $min )
	return 1000 * 60 * $min 
endfunc
func _spread( $n, $range )
	return $n + Random( - $range, $range, 1 )
endfunc








; Движок!
func INIT()
	sleep( $_sleepBeforeStart )

	$_w = WinWait( $_windowName )
	WinActivate( $_w )
	WinSetState( $_w, '', @SW_MAXIMIZE )

	if $_move then WinMove( $_w, "", $_movePos[ 0 ], $_movePos[ 1 ], $_moveSize[ 0 ], $_moveSize[ 1 ] )
	$_wPos = WinGetPos( $_w )

	if $_is_GUI then _GUI()

	_log( 'Window name: ' & WinGetTitle( $_w ) )
	;_log( 'Window pos : ' & $_wPos[ 0 ] & ' ' & $_wPos[ 1 ] )
	;_log( 'Window size: ' & $_wPos[ 2 ] & '*' & $_wPos[ 3 ] )

	_circle()

endfunc
;
;
;

func _GUI()
	
	Opt( "GUICoordMode", 1 )
	Opt( 'GUIOnEventMode', 1 )
	GUISetOnEvent( $GUI_EVENT_CLOSE, '_Exit' )
	
	$_gui = GUICreate( _
		$_botName, _
		$_wPos[ 2 ] - 10, _
		64, _
		$_wPos[ 0 ] + 5 , _
		$_wPos[ 3 ], _
		BitOr( $WS_MINIMIZEBOX, $WS_POPUP ), _
		0 _
	)
	GUISetState( @SW_SHOW )

	$_guiPos = WinGetPos( $_gui )

	if $_is_GUI_icon then
		$_gui_icon = GUICtrlCreatePic( $_gui_icon, 0, 32, 28, 28, -1, $WS_EX_CLIENTEDGE )
	endif

	if $_is_GUI_btn_getCPS then
		global $_gui_getCPS = GUICtrlCreateButton( _
			'GET CPS', _
			$_guiPos[ 2 ] - 452, _
			0, _
			32, _
			32, _
			BitOr( $BS_ICON, $BS_DEFPUSHBUTTON, $BS_FLAT ), _
			$WS_EX_CLIENTEDGE _
		)
		GUICtrlSetImage( -1, @SystemDir & '\shell32.dll', 22, 0 )
		GUICtrlSetOnEvent( $_gui_getCPS, '_gui_getCPS_fn' )
	endif

	if $_is_GUI_btn_getPos then
		global $_gui_getPos = GUICtrlCreateButton( _
			'GET Position', _
			$_guiPos[ 2 ] - 452, _
			32, _
			32, _
			32, _
			BitOr( $BS_ICON, $BS_DEFPUSHBUTTON, $BS_FLAT ), _
			$WS_EX_CLIENTEDGE _
		)
		GUICtrlSetImage( -1, @SystemDir & '\shell32.dll', 323, 0 )
		GUICtrlSetOnEvent( $_gui_getPos, '_gui_getPos_fn' )
	endif

	if $_is_GUI_btn_close then
		global $_gui_close = GUICtrlCreateButton( 'Close', 0, 0, 32, 32, BitOr( $BS_ICON, $BS_DEFPUSHBUTTON, $BS_FLAT ), $WS_EX_CLIENTEDGE )
		GUICtrlSetImage( -1, @SystemDir & '\shell32.dll', 240, 0 )
		GUICtrlSetOnEvent( $_gui_close, '_Exit' )
	endif

	if $_is_GUI_console then
		global $_gui_console = GUICtrlCreateEdit( _
			'--------------------------------------------- CONSOLE ---------------------------------------------', _
			$_guiPos[ 2 ] - 420, _
			0, _
			350, _
			64, _
			BitOr( $ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_MULTILINE ) _
		)

		global $_gui_console_time = GUICtrlCreateEdit( _
			'---TIME---', _
			$_guiPos[ 2 ] - 68, _
			0, _
			66, _
			64, _
			BitOr( $ES_WANTRETURN, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_MULTILINE ) _
		)
	endif

	WinActivate( $_w )


endfunc
; GUI Events Function
func _gui_getCPS_fn()
	sleep( 1500 )
	return _logCPS()
endfunc

func _gui_getPos_fn()
	sleep( 1500 )
	return _logPos()
endfunc
;
;
;

func _circle()
	while 1

		sleep( $_sleepInCircle )

		if $_isLogicCircle then

			GoLogic( '_General' )
			
		endif

	wend
endfunc

func GoLogic( $name )

	local $a = eval( $name )
	local $res = ''

	for $i = 0 to UBound( $a ) - 1 step 1

		if isCPS( $a, $i ) then
			$_X = $a[ $i ][ 0 ]
			$_Y = $a[ $i ][ 1 ]
			_log( '$' & $name & '[' & $i & '] MATCH = ' & $res )
			$res = Logic( $name, $i )

			if $res = 1 then exitloop

		endif

	next
endfunc












;
; INIT()
;
