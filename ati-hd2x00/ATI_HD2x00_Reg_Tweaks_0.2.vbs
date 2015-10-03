' 
' ATI HD2x00 Registry Tweaks for Maximum HTPC Performance
'
' Author: 	ExDeus		exdeus at comcast dot net
' Date: 	2007-09-17
' Version:	0.2
' 
' This script is designed to add values to the Windows registry.
' Changing anything in the registry can be hazardous.
' No warranty is offered or implied. Use at your own risk!
' 
' This script will add a number of registry tweaks to enhance the 
' performance of ATI HD2x00 video cards for use in HTPCs.
'
' You will be prompted several times before anything in the registry
' is changed.
'
' See http://www.avsforum.com/avs-vb/showpost.php?p=11622510&postcount=2011
' for references on the effects of each setting.
'


const HKEY_LOCAL_MACHINE = &H80000002
const REG_SZ = 1
const HKLM = "HKLM"

Dim arrHwValueNames, arrHwValueTypes
Dim strHwRegVal
Dim idx
Dim length
Dim strActiveVideoDevice
Dim strDeviceDescr
Dim blnHD2400

strComputer = "."		' this computer
strHwRegKey = "HARDWARE\DEVICEMAP\VIDEO"		' the reg key where the current video device is listed
strHwSearchStr = "System\CurrentControlSet\Control\Video\{"		' part of the string that should be found in the active video device
success = False

Dim arr2400RegKeys(12)
arr2400RegKeys(0) = Array("DXVA_DetailEnhance", "0")
arr2400RegKeys(1) = Array("DXVA_NOHDDECODE", "0")
arr2400RegKeys(2) = Array("DXVA_Only24FPS1080MPEG2", "0")
arr2400RegKeys(3) = Array("DXVA_Only24FPS1080H264", "0")
arr2400RegKeys(4) = Array("DXVA_Only24FPS1080VC1", "0")
arr2400RegKeys(5) = Array("DXVA_WMV_NA", "0")
arr2400RegKeys(6) = Array("SORTOverrideFPSCaps", "0")
arr2400RegKeys(7) = Array("TrDenoise", "0")
arr2400RegKeys(8) = Array("UseBT601CSC", "1")
arr2400RegKeys(9) = Array("VForce24FPS1080MPEG2", "0")
arr2400RegKeys(10) = Array("VForce24FPS1080H264", "0")
arr2400RegKeys(11) = Array("VForce24FPS1080VC1", "0")
arr2400RegKeys(12) = Array("VForceMaxResSize", "2800000")

Dim arr2600RegKeys(10)
arr2600RegKeys(0) = Array("ColorVibrance_DEF", "0")
arr2600RegKeys(1) = Array("ColorVibrance_DE_MIN", "0")
arr2600RegKeys(2) = Array("DI_METHOD", "5")
arr2600RegKeys(3) = Array("DI_METHOD_DEF", "5")
arr2600RegKeys(4) = Array("DXVA_DetailEnhance", "0")
arr2600RegKeys(5) = Array("DXVA_WMV_NA", "0")
arr2600RegKeys(6) = Array("Fleshtone_DEF", "0")
arr2600RegKeys(7) = Array("Fleshtone_DE_MIN", "0")
arr2600RegKeys(8) = Array("TrDenoise", "0")
arr2600RegKeys(9) = Array("UseBT601CSC", "1")
arr2600RegKeys(10) = Array("VForceMaxResSize", "2800000")

Set objShell = CreateObject("WScript.Shell")
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")


' Enumerate the values in the hardware device map for each video device
objReg.EnumValues HKEY_LOCAL_MACHINE, strHwRegKey, arrHwValueNames, arrHwValueTypes

For i=0 To UBound(arrHwValueNames)
	If arrHwValueTypes(i) = REG_SZ Then
		objReg.GetStringValue HKEY_LOCAL_MACHINE, strHwRegKey, arrHwValueNames(i), strHwRegVal
		
		' Check each video device for the first one listed under CurrentControlSet with a GUID
		idx = InStr(strHwRegVal, strHwSearchStr)
		
		If idx > 0 Then
			length = Len(strHwRegVal)
			strActiveVideoDevice = Right(strHwRegVal, length-idx+1)		' get the reg path to the active video device
			success = True
			Exit For
		End If
	End If
Next

If success Then
	success = False
	
	objReg.GetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, "Device Description", strDeviceDescr
	
	result = MsgBox("Does the following device look correct?" & vbCrLf & vbCrLF &_
		HKLM & "\" & strActiveVideoDevice & vbCrLf & vbCrLf &_
		"Device Description: " & strDeviceDescr,_
		vbYesNo+vbQuestion, "Found Video Device")
		
	If result = vbYes Then
		result = MsgBox("Do you have the HD2400? (Answer 'No' for the HD2600.)",_
			vbYesNo+vbQuestion, "Which video card?")
			
		If result = vbYes Then
			blnHD2400 = True
		Else
			blnHD2400 = False
		End If

		result = MsgBox("Do you want to add all registry entries? (Answer 'No' to approve each individually.)",_
			vbYesNo+vbQuestion, "Add all?")

		If result = vbYes Then
			If blnHD2400 Then
				For i=0 To UBound(arr2400RegKeys)				
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
				Next
			Else
				For i=0 To UBound(arr2600RegKeys)				
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
				Next
			End If
		Else
			If blnHD2400 Then
				For i=0 To UBound(arr2400RegKeys)
					result = MsgBox("Add " & arr2400RegKeys(i)(0) & " = " & arr2400RegKeys(i)(1) & " ?",_
						vbYesNo+vbQuestion, "Add This RegValue?")

					If result = vbYes Then
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
					End If
				Next
			Else
				For i=0 To UBound(arr2600RegKeys)
					result = MsgBox("Add " & arr2600RegKeys(i)(0) & " = " & arr2600RegKeys(i)(1) & " ?",_
						vbYesNo+vbQuestion, "Add This RegValue?")

					If result = vbYes Then
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
					End If
				Next
			End If
		End If
			
		' Done
		MsgBox "Unless you've seen some other error, we're done.", vbInformation, "Done" 
	Else	' Incorrect video device
		MsgBox "You clicked 'No'. Quitting.", vbExclamation, "Quitting" 
	End If
Else 	' success = 0
	MsgBox strHwSearchStr & " not found. Quitting.", vbExclamation, "Quitting" 
End If


