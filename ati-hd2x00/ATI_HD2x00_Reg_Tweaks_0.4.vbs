' 
' ATI HD2x00 Registry Tweaks for Maximum HTPC Performance
'
' Author: 	ExDeus		exdeus at comcast dot net
' Date: 	2007-09-18
' Version:	0.4
' 
' This script is designed to add values to the Windows registry.
' Changing anything in the registry can be hazardous.
' No warranty is offered or implied. Use at your own risk!
' 
' This script will add a number of registry tweaks to enhance the 
' performance of ATI HD2x00 video cards for use in HTPCs. It is
' compatible with Windows Vista, XP & MCE.
'
' To find the video device currently used by your ATI drivers, 
' open the Catalyst Control Center, and select the 
' Information Center > Graphics Software section. The 2D Driver Path
' will show the GUID (the number between the curly brackets, "{}")
' for your video device. That is the device you want to look for
' when running this program.
'
' You will be prompted to approve the correct video device before 
' anything in the registry is changed. To add settings for multiple
' devices, simply re-run the program and select a different device.
' For each device, the registry tweaks will be applied to both 
' outputs 0000 and 0001.'
' 
'
' See http://www.avsforum.com/avs-vb/showpost.php?p=11622510&postcount=2011
' for references on the effects of each setting.
'


'On Error Resume Next

const HKEY_LOCAL_MACHINE = &H80000002
const KEY_QUERY_VALUE = &H0001
const REG_SZ = 1
const HKLM = "HKLM"
const VISTA_DXVA = "\UMD\DXVA"

Dim arrHwValueNames, arrHwValueTypes, arrSubKeys
Dim strHwRegVal
Dim idx
Dim length
Dim strActiveVideoDevice
Dim strSecondaryVideoDevice
Dim strDeviceDescr
Dim strMsg
Dim blnHD2400

strComputer = "."		' this computer
strHwRegKey = "HARDWARE\DEVICEMAP\VIDEO"		' the reg key where the current video device is listed
strHwSearchStr = "System\CurrentControlSet\Control\Video\{"		' part of the string that should be found in the active video device
blnHasAccessRight = False
blnVista = False
success = False

Dim arr2400RegKeys(13)
arr2400RegKeys(0) = Array("DXVA_DetailEnhance", "0")
arr2400RegKeys(1) = Array("DXVA_NOHDDECODE", "0")
arr2400RegKeys(2) = Array("DXVA_Only24FPS1080MPEG2", "0")
arr2400RegKeys(3) = Array("DXVA_Only24FPS1080H264", "0")
arr2400RegKeys(4) = Array("DXVA_Only24FPS1080VC1", "0")
arr2400RegKeys(5) = Array("DXVA_WMV_NA", "0")
arr2400RegKeys(6) = Array("SORTOverrideFPSCaps", "0")
arr2400RegKeys(7) = Array("SORTOverrideVidSizeCaps", "2800000")  
arr2400RegKeys(8) = Array("TrDenoise", "0")
arr2400RegKeys(9) = Array("UseBT601CSC", "1")
arr2400RegKeys(10) = Array("VForce24FPS1080MPEG2", "0")
arr2400RegKeys(11) = Array("VForce24FPS1080H264", "0")
arr2400RegKeys(12) = Array("VForce24FPS1080VC1", "0")
arr2400RegKeys(13) = Array("VForceMaxResSize", "2800000")

Dim arr2600RegKeys(13)
arr2600RegKeys(0) = Array("ColorVibrance_DEF", "0")
arr2600RegKeys(1) = Array("ColorVibrance_DE_MIN", "0")
arr2600RegKeys(2) = Array("ColorVibrance_NA", "0")
arr2600RegKeys(3) = Array("DI_METHOD", "5")
arr2600RegKeys(4) = Array("DI_METHOD_DEF", "5")
arr2600RegKeys(5) = Array("DXVA_DetailEnhance", "0")
arr2600RegKeys(6) = Array("DXVA_WMV_NA", "0")
arr2600RegKeys(7) = Array("Fleshtone_DEF", "0")
arr2600RegKeys(8) = Array("Fleshtone_DE_MIN", "0")
arr2600RegKeys(9) = Array("Fleshtone_NA", "0")
arr2600RegKeys(10) = Array("SORTOverrideVidSizeCaps", "2800000")  
arr2600RegKeys(11) = Array("TrDenoise", "0")
arr2600RegKeys(12) = Array("UseBT601CSC", "1")
arr2600RegKeys(13) = Array("VForceMaxResSize", "2800000")

Set objShell = CreateObject("WScript.Shell")
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
Set objOS = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colOperatingSystems = objOS.ExecQuery("Select * from Win32_OperatingSystem")

For Each objItem in colOperatingSystems   
    If InStr(objItem.Caption, "Vista") Then
    	blnVista = True
    End If
Next

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
			objReg.GetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, "Device Description", strDeviceDescr
			
			' If Vista, check for the DXVA key
			If blnVista Then
				objReg.CheckAccess HKEY_LOCAL_MACHINE, strActiveVideoDevice & VISTA_DXVA, KEY_QUERY_VALUE, blnHasAccessRight
				
				If blnHasAccessRight Then
					strMsg = "Note: The " & VISTA_DXVA & " registry key is present. This is likely the correct device."
				Else
					strMsg = "Note: The " & VISTA_DXVA & " registry key is NOT present. This is likely not the correct device."
				End If
			End If						
			
			result = MsgBox("Does the following device look correct?" & vbCrLf & vbCrLF &_
				HKLM & "\" & strActiveVideoDevice & vbCrLf & vbCrLf &_
				"Device Description: " & strDeviceDescr & vbCrLf & vbCrLf &_
				strMsg, vbYesNo+vbQuestion, "Found Video Device")
			
			If result = vbYes Then
				success = True
				Exit For
			End If
		End If
	End If
Next

If success Then
	success = False
	
	' Get the key to add settings to the secondary display
	strSecondaryVideoDevice = Replace(strActiveVideoDevice, "\0000", "\0001", 1, 1)
	
	' If Vista, then create the DXVA keys, just in case. Will not overwrite if they are already present.
	If blnVista Then
		objReg.CreateKey HKEY_LOCAL_MACHINE, strActiveVideoDevice & VISTA_DXVA
		objReg.CreateKey HKEY_LOCAL_MACHINE, strSecondaryVideoDevice & VISTA_DXVA
	End If

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
				If blnVista Then
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice & VISTA_DXVA, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice & VISTA_DXVA, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
				Else
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
				End If
			Next
		Else
			For i=0 To UBound(arr2600RegKeys)
				If blnVista Then
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice & VISTA_DXVA, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice & VISTA_DXVA, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
				Else
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
					objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
				End If
			Next
		End If
	Else
		If blnHD2400 Then
			For i=0 To UBound(arr2400RegKeys)
				result = MsgBox("Add " & arr2400RegKeys(i)(0) & " = " & arr2400RegKeys(i)(1) & " ?",_
					vbYesNo+vbQuestion, "Add This RegValue?")

				If result = vbYes Then
					If blnVista Then
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice & VISTA_DXVA, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice & VISTA_DXVA, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
					Else
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice, arr2400RegKeys(i)(0), arr2400RegKeys(i)(1)
					End If
				End If
			Next
		Else
			For i=0 To UBound(arr2600RegKeys)
				result = MsgBox("Add " & arr2600RegKeys(i)(0) & " = " & arr2600RegKeys(i)(1) & " ?",_
					vbYesNo+vbQuestion, "Add This RegValue?")

				If result = vbYes Then
					If blnVista Then
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice & VISTA_DXVA, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice & VISTA_DXVA, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
					Else
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strActiveVideoDevice, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
						objReg.SetStringValue HKEY_LOCAL_MACHINE, strSecondaryVideoDevice, arr2600RegKeys(i)(0), arr2600RegKeys(i)(1)
					End If
				End If
			Next
		End If
	End If

	' Done
	MsgBox "Unless you've seen some other error, we're done.", vbInformation, "Done" 
Else 	' success = 0
	MsgBox "A valid video device was not found. Quitting.", vbExclamation, "Quitting" 
End If



