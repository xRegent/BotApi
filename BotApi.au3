;;;
;;; BotApi - API ��� �������� ����������� ������� �� ����� autoit
;;;
;;; @home: http://l-i-v-e.ru/
;;; @autor: Aleks Regent
;;; @version: 0.1
;;;

;;;
;;; CPS - COORDINATES with PixelSum
;;;     - ������ ������� �� 3-� ���������, ������ ��� � ������� �������� ������������ X � Y
;;;       � ���� ��������� ���������(����� ��������� �� ������� ����� ����� ���������)
;;;       ������ ������� ������� - ����������� ����� �������� �������� 5*3 � ������� � ����������� X � Y
;;;
#include <MsgBoxConstants.au3>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; VARS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global $Window, $WindowPos
$WindowName = "[ACTIVE]"                         ; ��� ����
;
$IsMove = 1                                      ; ���������� ���� � �������� ��� ������� ��� ������?
$MoveWidth = 1600                                ; ����� ������� � ���������� ���� [ 1280 x 720, 1366 x 768, 1536 x 864, 1600 x 900, 1920 x 1080 ]
$MoveHeight = 900                                ; -||-
$MoveX = @DesktopWidth / 2 - $MoveWidth / 2      ; -||-
$MoveY = @DesktopHeight / 2 - $MoveHeight / 2    ; -||-
;
$MouseSpeed = 0                                  ; �������� �������� ���� ��� ����� (0-10)
Dim $MouseDefaultPos[2] = [ 10, 10 ]             ; ������� ���� �� ���������
$MouseSpeedToDefault = 0                         ; �������� �������� ���� ��� ����� (0-10)
$SleepBeforeClick = 10                           ; ����� �� ����� MS
$SleepAfterClick = 10                            ; ����� ����� ����� MS
;
$isCircle = 0                               ; ������ ������������ �����
;
$BtnKill = "{ESC}"                          ; ������ ���������� ����������
$BtnStartCircle = "{F1}"                    ; ��������� ����������� ����
$BtnStopCircle = "{F2}"                     ; ���������� ����������� ����
$BtnGetCPS = "{F5}"                         ; �������� ���������� ������� � ���������� � ����������� ����� �������� � ���� �����������(CPS)
;
Dim $ArrayPixClick[1][3]   = [[0,0,0]]      ; ������ ������ ��� ������ �� �������� �������� - ��������� � ������� ���������
Dim $ArrayLogic[1][3]      = [[0,0,0]]      ; ������ ��� ������
;
$SleepBeforeStart = 3000                    ; �������� ����� ������� ������
$SleepBeforeEnd   = 10000                   ; �������� �� ���������� ��������
$SleepInCircle    = 500                     ; �������� � �����
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ��������� ����������
HotKeySet( $BtnKill, "Kill" )
Func Kill()
	Exit
EndFunc

; ��������� ����������� ���� ��������� ������
HotKeySet( $BtnStartCircle, "StartCircle" )
Func StartCircle()
	if $isCircle = 0 then
		$isCircle = 1
		Circle()
	endif
EndFunc

; ���������� ����������� ����
HotKeySet( $BtnStopCircle, "StopCircle" )
Func StopCircle()
	$isCircle = 0
	sleep( $SleepBeforeEnd )
	Exit
EndFunc

; �������� ���������� ������� � ���������� � ����������� ����� �������� � ���� �����������
; �. �. �������� ������ � ������� CPS
HotKeySet( $BtnGetCPS, "GetCPS" )
Func GetCPS()
	local $m = MouseGetPos()
	log_( 'Real coords: ' & $m[0] & ' ' & $m[1] )
	local $c[4] = [ $m[0] - 2, $m[1] - 1, $m[0] + 2, $m[1] + 1 ]
	GoDefaultMouse()
	sleep( 100 )
	$m = toProgramCoords( $m )
	log_( 'Program coords: ' & $m[0] & ' ' & $m[1] )
	local $n = PixelChecksum( $c[0], $c[1], $c[2], $c[3] )
	$mess = '[' & $m[0] & ',' & $m[1] & ',' & $n & ']'
	log_( $mess, 1 )
	MouseMove( $c[ 0 ], $c[ 1 ], 10 )
	sleep( 400 )
	MouseMove( $c[ 2 ], $c[ 3 ], 10 )
	sleep( 400 )
	WinActivate( "[CLASS:SciTEWindow]" )
	Kill()
EndFunc

; ��������� ���� � ������� �� ���������
func GoDefaultMouse()
	local $a = toRealCoords( $MouseDefaultPos )
	MouseMove( $a[ 0 ], $a[ 1 ], $MouseSpeedToDefault )
endfunc

; ��������� ������
func alert( $mess, $type = 0 )
	MsgBox( $type,'', $mess )
endfunc

; ���������� � ����� ������
func copy( $mess )
	Clipput( $mess )
endfunc

; ��������� ��������� � �������
func log_( $mess, $isCopy = 0 )
	if $isCopy then copy( $mess )
	ConsoleWrite( '********** |- ' & $mess & @LF )
endfunc

; ��������������� � ���������� ������������ ���� ���������
Func toProgramCoords( $arr )
	local $a = $arr;
	$a[0] = $arr[0] - $WindowPos[0]
	$a[1] = $arr[1] - $WindowPos[1]
	Return $a;
EndFunc
; ��������������� � ���������� �� ������������� � ��������� � ������������� � �������
Func toRealCoords( $arr )
	local $a = $arr;
	$a[0] = $arr[0] + $WindowPos[0]
	$a[1] = $arr[1] + $WindowPos[1]
	Return $a;
EndFunc

; �������� �� ������� CPS �� �������
func isCPSinDisplay( $CPSmultiArray, $CPS_index )
	local $arr = GetArray( $CPSmultiArray, $CPS_index )
	$arr = toRealCoords( $arr )
	local $pix = PixelChecksum( $arr[0] - 2, $arr[1] - 1, $arr[0] + 2, $arr[1] + 1 )
	return $pix = $arr[ 2 ]
endfunc

; �������� ������ � �������� $index �� ������������ ������� $multiArray
func GetArray( $multiArray, $index )
	local $len = UBound( $multiArray, 2 )
	local $newArr[ $len ]
	for $i = 0 to $len -1 step 1
		$newArr[ $i ] = $multiArray[ $index ][ $i ]
	next
	return $newArr
endfunc

; ���� �� CPS �� �������
func clickCPS( $CPSmultiArray, $CPS_index )
	local $arr = GetArray( $CPSmultiArray, $CPS_index )
	$arr = toRealCoords( $arr )
	return click( $arr[ 0 ], $arr[ 1 ] )
endfunc

; ���� �� �������� X � Y �� �������
func click( $x, $y )
	sleep( $SleepBeforeClick )
	MouseClick( '', $x, $y, 5, $MouseSpeed )
	GoDefaultMouse()
	sleep( $SleepAfterClick )
endfunc









; ������!
func INIT()
	sleep( $SleepBeforeStart )

	$Window = WinWait( $WindowName )
	WinActivate( $Window )
	WinSetState( $Window, '', @SW_MAXIMIZE )

	if $IsMove then WinMove( $Window, "", $MoveX, $MoveY, $MoveWidth, $MoveHeight )
	$WindowPos = WinGetPos( $Window )

	log_( 'Window name: ' & WinGetTitle( $Window ) )
	log_( 'Window pos : ' & $WindowPos[0] & ' ' & $WindowPos[1] )
	log_( 'Window size: ' & $WindowPos[2] & '*' & $WindowPos[3] )

	sleep( $SleepBeforeEnd )
endfunc

func Circle()
	log_( 'Circle start!' )
	while $isCircle

		sleep( $SleepInCircle )

		; Logic Circle
		for $i = 0 to UBound( $ArrayLogic ) - 1 step 1
			if isCPSinDisplay( $ArrayLogic, $i ) then
				if Logic( $i ) then exitloop
			endif
		next

		; Click Circle
		for $i = 0 to UBound( $ArrayPixClick ) - 1 step 1
			if isCPSinDisplay( $ArrayPixClick, $i ) then
				if NOT LogicBeforeClick( $i ) then
					clickCPS( $ArrayPixClick, $i )
				else
					exitloop
				endif
				if LogicAfterClick( $i ) then
					exitloop
				endif
			endif
		next

	wend
endfunc
;