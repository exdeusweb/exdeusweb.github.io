' 
' ATI HD Registry Tweaks for Maximum HTPC Performance
'
' Author: 	ExDeus		exdeus at comcast dot net
' Website:	http://home.comcast.net/~exdeus/ati-hd2x00/
' Date: 	2009-12-31
' Version:	0.16
'
' Suports Windows 7, Vista, XP & MCE. 
' 
' This script is designed to add values to the Windows registry.
' Changing anything in the registry can be hazardous.
' No warranty is offered or implied. Use at your own risk!
' 
' This script will add a number of registry tweaks to enhance the 
' performance of ATI HD2000, HD3000, HD4000, and HD5000 series video cards 
' for use in HTPCs. 
'
' Double-click to run.
'
' You will be prompted to approve the correct video device before 
' anything in the registry is changed. To add settings for multiple
' devices, simply re-run the program and select a different device.
' In Windows XP / MCE, the registry tweaks will be applied to all outputs,
' e.g., 0000 and 0001. In Windows 7 / Vista, the registry tweaks are applied
' uniformly to the active device, which applies to all outputs on that
' device.
'
'
' See http://www.avsforum.com/avs-vb/showpost.php?p=11622510&postcount=2011
' for details on the registry settings.
'
' See http://www.avsforum.com/avs-vb/showpost.php?p=11659897&postcount=2121
' for details on the effects of each setting.
'
'
' This software is licensed under the Microsoft Reciprocal License (Ms-RL)

' This license governs use of the accompanying software. If you use the software, you accept this license. If you do not accept the license, do not use the software.

' 1. Definitions
' The terms "reproduce," "reproduction," "derivative works," and "distribution" have the same meaning here as under U.S. copyright law.
' A "contribution" is the original software, or any additions or changes to the software.
' A "contributor" is any person that distributes its contribution under this license.
' "Licensed patents" are a contributor's patent claims that read directly on its contribution.

' 2. Grant of Rights
' (A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create.
' (B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.

' 3. Conditions and Limitations
' (A) Reciprocal Grants- For any file you distribute that contains code from the software (in source code or binary format), you must provide recipients the source code to that file along with a copy of this license, which license will govern that file. You may license other files that are entirely your own work and do not contain code from the software under any terms you choose.
' (B) No Trademark License- This license does not grant you rights to use any contributors' name, logo, or trademarks.
' (C) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically.
' (D) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software.
' (E) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license.
' (F) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.



'On Error Resume Next

const HKEY_LOCAL_MACHINE = &H80000002
const KEY_QUERY_VALUE = &H0001
const KEY_SET_VALUE = &H0002
const KEY_CREATE_SUB_KEY = &H0004
const DELETE = &H00010000
const REG_SZ = 1
const REG_EXPAND_SZ = 2
const REG_BINARY = 3
const REG_DWORD = 4
const REG_MULTI_SZ = 7
const HKLM = "HKLM"
const VISTA_DXVA = "\UMD\DXVA"
const VISTA_DEV_DESC = "\Settings"

Dim arrHwValueNames, arrHwValueTypes, arrVideoKeys, arrVideoDevices
Dim blnHD2400
Dim idx
Dim length
Dim result
Dim strHwRegVal, strRegVal
Dim strVideoGUID
Dim strActiveVideoDevice, strSecondaryVideoDevice
Dim strDeviceDescr
Dim strMsg


strComputer = "."		' this computer
strHwRegKey = "HARDWARE\DEVICEMAP\VIDEO"		' the reg key where the current video device is listed
strHwSearchStr = "System\CurrentControlSet\Control\Video\{"		' part of the string that should be found in the active video device
strVistaKey = "SYSTEM\CurrentControlSet\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}"
blnHasAccessRight = False
blnVista = False
success = False

Dim arr2400RegKeys
arr2400RegKeys = Array(_
	Array("Denoise_NA", "0", "Enables the Denoise slider in the CCC."),_
	Array("Detail_NA", "0", "Enables the Detail slider in the CCC."),_
	Array("DXVA_DetailEnhance", "0", "Disables detail (edge) enhancement."),_
	Array("DXVA_NOHDDECODE", "0", "Enables HD MPEG2 decoding."),_
	Array("DXVA_Only24FPS1080MPEG2", "0", "Enables MPEG2 decoding for formats other than 1080@24fps."),_
	Array("DXVA_Only24FPS1080H264", "0", "Enables H.264 decoding for formats other than 1080@24fps."),_
	Array("DXVA_Only24FPS1080VC1", "0", "Enables VC-1 decoding for formats other than 1080@24fps."),_
	Array("DXVA_WMV_NA", "0", "Enables WMV acceleration checkbox."),_
	Array("HWUVD_ForceMPEG2", "1", "Enables MPEG2 decoding using VMR9 with dual displays."),_
	Array("SORTOverrideFPSCaps", "0", "Enables decoding for various framerates (applies to Catalyst 7.7 and earlier)."),_
	Array("SORTOverrideVidSizeCaps", "2800000", "Enables fullscreen decoding for 1080p displays (applies to Catalyst 7.7 and earlier).")  ,_
	Array("TrDenoise", "0", "Disables denoising for both HD and SD."),_
	Array("UseBT601CSC", "1", "Enables use of consistent colorspaces for HD and SD."),_
	Array("VForce24FPS1080MPEG2", "0", "Enables MPEG2 decoding for formats other than 1080@24fps."),_
	Array("VForce24FPS1080H264", "0", "Enables H.264 decoding for formats other than 1080@24fps."),_
	Array("VForce24FPS1080VC1", "0", "Enables VC-1 decoding for formats other than 1080@24fps."),_
	Array("VForceDeint", "6", "Enables all deinterlacing modes (Motion Adaptive, Vector Adaptive)."),_
	Array("VForceHDDenoise", "0", "Disables denoising only for HD."),_
	Array("VForceMaxResSize", "2800000", "Enables fullscreen decoding for 1080p displays (applies to Catalyst 7.8 and later)."),_
	Array("VForceUVDH264", "1", "Enables H.264 decoding with dual displays."),_
	Array("VForceUVDVC1", "1", "Enables VC-1 decoding with dual displays.")_
)

Dim arr2600RegKeys 
arr2600RegKeys = Array(_
	Array("ColorVibrance_DEF", "0", "Disables Color Vibrance control (must also use ColorVibrance_DE_MIN)."),_
	Array("ColorVibrance_DE_MIN", "0", "Disables Color Vibrance control (must also use ColorVibrance_DEF)."),_
	Array("ColorVibrance_NA", "0", "Enables the Color Vibrance slider in the CCC."),_
	Array("Denoise_NA", "0", "Enables the Denoise slider in the CCC."),_
	Array("Detail_NA", "0", "Enables the Detail slider in the CCC."),_
	Array("DI_METHOD", "5", "Enables Vector Adaptive deinterlacing (must also use DI_METHOD_DEF)."),_
	Array("DI_METHOD_DEF", "5", "Enables Vector Adaptive deinterlacing (must also use DI_METHOD)."),_
	Array("DXVA_DetailEnhance", "0", "Disables detail (edge) enhancement."),_
	Array("DXVA_NOHDDECODE", "0", "Enables HD MPEG2 decoding."),_
	Array("DXVA_WMV_NA", "0", "Enables WMV acceleration checkbox."),_
	Array("Fleshtone_DEF", "0", "Disables Fleshtone control (must also use Fleshtone_DE_MIN)."),_
	Array("Fleshtone_DE_MIN", "0", "Disables Fleshtone control (must also use Fleshtone_DEF)."),_
	Array("Fleshtone_NA", "0", "Enables the Fleshtone slider in the CCC."),_
	Array("HWUVD_ForceMPEG2", "1", "Enables MPEG2 decoding using VMR9 with dual displays."),_
	Array("SORTOverrideVidSizeCaps", "2800000", "Enables fullscreen decoding for 1080p displays (applies to Catalyst 7.7 and earlier).")  ,_
	Array("TrDenoise", "0", "Disables denoising for both HD and SD."),_
	Array("UseBT601CSC", "1", "Enables use of consistent colorspaces for HD and SD."),_
	Array("VForceHDDenoise", "0", "Disables denoising only for HD."),_
	Array("VForceMaxResSize", "2800000", "Enables fullscreen decoding for 1080p displays (applies to Catalyst 7.8 and later)."),_
	Array("VForceUVDH264", "1", "Enables H.264 decoding with dual displays."),_
	Array("VForceUVDVC1", "1", "Enables VC-1 decoding with dual displays.")_
)

Set objShell = CreateObject("WScript.Shell")
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
Set objOS = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colOperatingSystems = objOS.ExecQuery("Select * from Win32_OperatingSystem")


For Each objItem in colOperatingSystems   
    If InStr(1, objItem.Caption, "Vista", 1) Or InStr(1, objItem.Caption, "Windows 7", 1) Then
    	blnVista = True
    End If
Next

If blnVista Then ' Vista
	' If Vista, check for access rights
	objReg.CheckAccess HKEY_LOCAL_MACHINE, strVistaKey, KEY_QUERY_VALUE, blnHasAccessRight

	If blnHasAccessRight Then
		' Enumerate the subkeys (video devices) under the GUID
		objReg.EnumKey HKEY_LOCAL_MACHINE, strVistaKey, arrVideoKeys
				
		strVistaKey = strVistaKey & "\"
		
		For Each strVideoKey In arrVideoKeys
			' Each video device has a numeric key, i.e., "0000" or "0001"
			If IsNumeric(strVideoKey) Then
				objReg.GetStringValue HKEY_LOCAL_MACHINE, strVistaKey & strVideoKey & VISTA_DEV_DESC, "Device Description", strDeviceDescr	
													
				result = MsgBox("Does the following device look correct?" & vbCrLf & vbCrLF &_
					HKLM & "\" & strVistaKey & strVideoKey & vbCrLf & vbCrLf &_
					"Device Description: " & strDeviceDescr & vbCrLf & vbCrLf &_
					strMsg, vbYesNo+vbQuestion, "Found Video Device")

				If result = vbYes Then
					success = True
					strActiveVideoDevice = strVideoKey
					Exit For
				End If
			End If
		Next
	Else ' No registry access
		success = False
		
		result = MsgBox("You do not have permission to query the registry key:" & vbCrLf & vbCrLf &_
			HKLM & "\" & strVistaKey & vbCrLf & vbCrLf &_
			"Check that UAC is disabled or set to prompt for approval." & vbCrLf & vbCrLf &_
			"Would you like to open the following links in a web browser to learn more about UAC?" &_
			vbCrLf & vbCrLf &_
			"How to use User Account Control (UAC) in Windows Vista: " & vbCrLf &_
			"http://support.microsoft.com/kb/922708/en-us" & vbCrLf &_
			"Turn User Account Control on or off: " & vbCrLf &_
			"http://windowshelp.microsoft.com/Windows/en-US/Help/58b3b879-924d-4e08-9358-c316055d3eae1033.mspx",_
			vbYesNo+vbCritical, "Access Denied")
			
		If result = vbYes Then
			objShell.Run("http://windowshelp.microsoft.com/Windows/en-US/Help/58b3b879-924d-4e08-9358-c316055d3eae1033.mspx")
			objShell.Run("http://support.microsoft.com/kb/922708/en-us")
		End If
	End If

Else ' XP
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
End If



If success Then
	success = False
	
	If blnVista Then 
		' With the current design, the program will only add the settings for one device at a time.
		' Under the Control\Class key (used for Vista), the numbered keys represent devices,
		' whereas under the Control\Video key (used for XP), the numbered keys represent ports on a device.
		ReDim arrVideoDevices(0)		
		arrVideoDevices(0) = strActiveVideoDevice
		
		' Create the DXVA keys, just in case. Will not overwrite if they are already present.
		For Each strVideoDevice In arrVideoDevices	
			objReg.CreateKey HKEY_LOCAL_MACHINE, strVistaKey & strVideoDevice & VISTA_DXVA
		Next
	Else ' XP
		' Get the video device key up to the GUID
		idx = InStrRev(strActiveVideoDevice, "\")	
		strVideoGUID = Left(strActiveVideoDevice, idx)

		' Enumerate the subkeys (video ports) under the GUID
		objReg.EnumKey HKEY_LOCAL_MACHINE, strVideoGUID, arrVideoKeys
	
		' Start index at -1 so that it redims the array to the correct size
		idx = -1

		' Find each video port (has a numeric key)
		For Each strVideoKey In arrVideoKeys
			If IsNumeric(strVideoKey) Then
				idx = idx + 1	
			End If		
		Next

		' ReDim video device array to size of num of video devices (actually each port)
		ReDim arrVideoDevices(idx)
		idx = 0

		' Copy each numeric value into the video device array
		For Each strVideoKey In arrVideoKeys
			If IsNumeric(strVideoKey) Then
				arrVideoDevices(idx) = strVideoKey
				idx = idx + 1	
			End If		
		Next
	End If
	

	result = MsgBox("Do you have the ATI HD2400 video card?" & vbCrLf & vbCrLf &_
		"Answer 'No' for the ATI HD2600, HD3000, HD4000, or HD5000 series.",_
		vbYesNo+vbQuestion, "Which video card?")

	If result = vbYes Then
		blnHD2400 = True
	Else
		blnHD2400 = False
	End If
	
	result = MsgBox("Do you want to ADD registry entries? (Answer 'No' to DELETE registry entries.)",_
		vbYesNo+vbQuestion, "Add or Delete?")
		
	If result = vbYes Then
		result = MsgBox("Do you want to ADD ALL registry entries? (Answer 'No' to approve each individually.)",_
			vbYesNo+vbQuestion, "Add all?")

		If result = vbYes Then
			If blnHD2400 Then
				If blnVista Then
					For Each strVideoDevice In arrVideoDevices
						For Each arr2400RegKey In arr2400RegKeys
							SetRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0), arr2400RegKey(1)
						Next
					Next
				Else ' XP
					For Each strVideoDevice In arrVideoDevices
						For Each arr2400RegKey In arr2400RegKeys
							SetRegValue strVideoGUID & strVideoDevice, arr2400RegKey(0), arr2400RegKey(1)
						Next
					Next
				End If
			Else ' HD2600, HD3000, HD4000
				If blnVista Then
					For Each strVideoDevice In arrVideoDevices
						For Each arr2600RegKey In arr2600RegKeys
							SetRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0), arr2600RegKey(1)
						Next
					Next
				Else ' XP
					For Each strVideoDevice In arrVideoDevices
						For Each arr2600RegKey In arr2600RegKeys
							SetRegValue strVideoGUID & strVideoDevice, arr2600RegKey(0), arr2600RegKey(1)
						Next
					Next
				End If
			End If
		Else ' Do not add all entries
			If blnHD2400 Then
				For Each arr2400RegKey In arr2400RegKeys
					result = MsgBox("Add " & arr2400RegKey(0) & " = " & arr2400RegKey(1) & " ?" & vbCrLf & vbCrLf & arr2400RegKey(2),_
						vbYesNo+vbQuestion, "Add This RegValue?")	

					If result = vbYes Then
						If blnVista Then
							For Each strVideoDevice In arrVideoDevices
								SetRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0), arr2400RegKey(1)
							Next
						Else
							For Each strVideoDevice In arrVideoDevices
								SetRegValue strVideoGUID & strVideoDevice, arr2400RegKey(0), arr2400RegKey(1)
							Next
						End If
					End If
				Next
			Else ' HD2600, HD3000, HD4000
				For Each arr2600RegKey In arr2600RegKeys
					result = MsgBox("Add " & arr2600RegKey(0) & " = " & arr2600RegKey(1) & " ?" & vbCrLf & vbCrLf & arr2600RegKey(2),_
						vbYesNo+vbQuestion, "Add This RegValue?")	

					If result = vbYes Then
						If blnVista Then
							For Each strVideoDevice In arrVideoDevices
								SetRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0), arr2600RegKey(1)
							Next
						Else
							For Each strVideoDevice In arrVideoDevices
								SetRegValue strVideoGUID & strVideoDevice, arr2600RegKey(0), arr2600RegKey(1)
							Next
						End If
					End If
				Next
			End If
		End If
	Else ' Delete registry values
		result = MsgBox("Do you want to DELETE ALL registry entries? (Answer 'No' to approve each individually.)",_
			vbYesNo+vbQuestion, "Delete all?")

		If result = vbYes Then
			If blnHD2400 Then
				If blnVista Then
					For Each strVideoDevice In arrVideoDevices
						For Each arr2400RegKey In arr2400RegKeys
							DeleteRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0)
						Next
					Next
				Else ' XP
					For Each strVideoDevice In arrVideoDevices
						For Each arr2400RegKey In arr2400RegKeys
							DeleteRegValue strVideoGUID & strVideoDevice, arr2400RegKey(0)
						Next
					Next
				End If
			Else ' HD2600, HD3000, HD4000, HD5000
				If blnVista Then
					For Each strVideoDevice In arrVideoDevices
						For Each arr2600RegKey In arr2600RegKeys
							DeleteRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0)
						Next
					Next
				Else ' XP
					For Each strVideoDevice In arrVideoDevices
						For Each arr2600RegKey In arr2600RegKeys
							DeleteRegValue strVideoGUID & strVideoDevice, arr2600RegKey(0)
						Next
					Next
				End If
			End If
		Else ' Do not delete all entries
			If blnHD2400 Then
				For Each arr2400RegKey In arr2400RegKeys
					If blnVista Then
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0))
							
							If Not IsNull(strRegVal) Then
								result = MsgBox("Delete " & strVistaKey & strVideoDevice & VISTA_DXVA & "\" & arr2400RegKey(0) & " = " & strRegVal & " ?" &_ 
									vbCrLf & vbCrLf & arr2400RegKey(2), vbYesNo+vbQuestion, "Delete This RegValue?")

								If result = vbYes Then
									DeleteRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0)
								End If
							End If
						Next
					Else
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVideoGUID & strVideoDevice, arr2400RegKey(0))
							
							If Not IsNull(strRegVal) Then
								result = MsgBox("Delete " & strVideoGUID & strVideoDevice & "\" & arr2400RegKey(0) & " = " & strRegVal & " ?" &_
									vbCrLf & vbCrLf & arr2400RegKey(2), vbYesNo+vbQuestion, "Delete This RegValue?")

								If result = vbYes Then
									DeleteRegValue strVideoGUID & strVideoDevice, arr2400RegKey(0)
								End If
							End If
						Next
					End If
				Next
			Else ' HD2600, HD3000, HD4000, HD5000
				For Each arr2600RegKey In arr2600RegKeys
					If blnVista Then
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0))
							
							If Not IsNull(strRegVal) Then
								result = MsgBox("Delete " & strVistaKey & strVideoDevice & VISTA_DXVA & "\" & arr2600RegKey(0) & " = " & strRegVal & " ?" &_
									vbCrLf & vbCrLf & arr2600RegKey(2), vbYesNo+vbQuestion, "Delete This RegValue?")

								If result = vbYes Then
									DeleteRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0)
								End If
							End If
						Next
					Else
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVideoGUID & strVideoDevice, arr2600RegKey(0))
							
							If Not IsNull(strRegVal) Then
								result = MsgBox("Delete " & strVideoGUID & strVideoDevice & "\" & arr2600RegKey(0) & " = " & strRegVal & " ?" &_
									vbCrLf & vbCrLf & arr2600RegKey(2), vbYesNo+vbQuestion, "Delete This RegValue?")

								If result = vbYes Then
									DeleteRegValue strVideoGUID & strVideoDevice, arr2600RegKey(0)
								End If
							End If
						Next
					End If
				Next
			End If
		End If
	End If

	' Done
	Call(Done)
Else 	' success = 0
	MsgBox "A valid video device was not found. Quitting.", vbExclamation, "Quitting" 
End If


Sub Done()
	strMsg =""
	
	If blnHD2400 Then
		If blnVista Then
			For Each strVideoDevice In arrVideoDevices
				strMsg = strMsg & vbCrLf & HKLM & "\" & strVistaKey & strVideoDevice & VISTA_DXVA & vbCrLf & vbCrLf
				
				For Each arr2400RegKey In arr2400RegKeys
					objReg.GetStringValue HKEY_LOCAL_MACHINE, strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0), strRegVal
					strMsg = strMsg & arr2400RegKey(0) & " = " & strRegVal & vbCrLf
				Next
			Next
		Else ' XP
			For Each strVideoDevice In arrVideoDevices
				strMsg = strMsg & vbCrLf & HKLM & "\" & strVideoGUID & strVideoDevice & vbCrLf & vbCrLf

				For Each arr2400RegKey In arr2400RegKeys
					objReg.GetStringValue HKEY_LOCAL_MACHINE, strVideoGUID & strVideoDevice, arr2400RegKey(0), strRegVal
					strMsg = strMsg & arr2400RegKey(0) & " = " & strRegVal & vbCrLf
				Next
			Next
		End If
	Else ' HD2600, HD3000, HD4000, HD5000
		If blnVista Then
			For Each strVideoDevice In arrVideoDevices
				strMsg = strMsg & vbCrLf & HKLM & "\" & strVistaKey & strVideoDevice & VISTA_DXVA & vbCrLf & vbCrLf
				
				For Each arr2600RegKey In arr2600RegKeys
					objReg.GetStringValue HKEY_LOCAL_MACHINE, strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0), strRegVal
					strMsg = strMsg & arr2600RegKey(0) & " = " & strRegVal & vbCrLf
				Next
			Next
		Else ' XP
			For Each strVideoDevice In arrVideoDevices
				strMsg = strMsg & vbCrLf & HKLM & "\" & strVideoGUID & strVideoDevice & vbCrLf & vbCrLf
				
				For Each arr2600RegKey In arr2600RegKeys
					objReg.GetStringValue HKEY_LOCAL_MACHINE, strVideoGUID & strVideoDevice, arr2600RegKey(0), strRegVal
					strMsg = strMsg & arr2600RegKey(0) & " = " & strRegVal & vbCrLf
				Next
			Next
		End If
	End If
	
	MsgBox "Unless you've seen some other error, we're done. The message below may truncate if too long." & vbCrLf & vbCrLF &_
		"The following are the current settings (blank values indicate no setting):" & vbCrLf & vbCrLf &_
		strMsg, vbInformation, "Done" 
	
	WScript.Quit
End Sub


Sub SetRegValue(aKey, aRegValName, aRegVal) 

	success = True
	
	If StrComp(aRegValName, "HWUVD_ForceMPEG2") = 0 Then
		result = MsgBox(aRegValName & " should only be applied when using dual displays." & vbCrLf & vbCrLf &_
					"Even with dual displays, the setting should only be applied if DXVA is not working. " &_
					"It is recommended to try using the ATI Avivo decoder without applying the setting. " &_
					vbCrLf & vbCrLf & "Key: " & aKey & vbCrLf & vbCrLf &_
					"Are you sure you want to apply the setting?",_
					vbYesNo+vbQuestion, "Are you sure?")
					
		If result = vbYes Then
			success = True
		Else
			success = False
		End If
	End If
	
	If success Then
		objReg.CheckAccess HKEY_LOCAL_MACHINE, aKey, KEY_SET_VALUE, blnHasAccessRight

		If blnHasAccessRight Then
			objReg.SetStringValue HKEY_LOCAL_MACHINE, aKey, aRegValName, aRegVal
		Else
			strMsg = "You do not have permission to set the registry key value:" & vbCrLf & vbCrLf &_
				HKLM & "\" & aKey & "\" & aRegValName

			If blnVista Then
				strMsg = strMsg & vbCrLf & vbCrLf & "Check that UAC is disabled or set to prompt for approval."
			End If

			strMsg = strMsg & vbCrLf & vbCrLf & "Abort (exit the program), Retry (try this setting again), " &_
				"or Ignore (skip this setting for this device)?"

			result = MsgBox(strMsg, vbAbortRetryIgnore+vbExclamation, "Access Denied")

			Select Case result
				Case vbRetry
					
					SetRegValue aKey, aRegValName, aRegVal
				Case vbIgnore
					' Do nothing
				Case Else
					Call(Done)			
			End Select 
		End If
	End If
End Sub


Function ReadRegValue(aKey, aRegValName) 
	Dim strRegValue
	
	objReg.CheckAccess HKEY_LOCAL_MACHINE, aKey, KEY_QUERY_VALUE, blnHasAccessRight
		
	If blnHasAccessRight Then
		objReg.GetStringValue HKEY_LOCAL_MACHINE, aKey, aRegValName, strRegValue	
	Else
		strRegValue = Null
		
		strMsg = "You do not have permission to read the registry key value:" & vbCrLf & vbCrLf &_
			HKLM & "\" & aKey & "\" & aRegValName

		If blnVista Then
			strMsg = strMsg & vbCrLf & vbCrLf & "Check that UAC is disabled or set to prompt for approval."
		End If

		strMsg = strMsg & vbCrLf & vbCrLf & "Abort (exit the program), Retry (try this setting again), " &_
			"or Ignore (skip this setting for this device)?"

		result = MsgBox(strMsg, vbAbortRetryIgnore+vbExclamation, "Access Denied")

		Select Case result
			Case vbRetry
				strRegValue = ReadRegValue(aKey, aRegValName) 
			Case vbIgnore
				' Do nothing
			Case Else
				Call(Done)			
		End Select 
	End If
	
	ReadRegValue = strRegValue
End Function


Sub DeleteRegValue(aKey, aRegValName) 
	objReg.CheckAccess HKEY_LOCAL_MACHINE, aKey, DELETE, blnHasAccessRight
		
	If blnHasAccessRight Then
		objReg.DeleteValue HKEY_LOCAL_MACHINE, aKey, aRegValName
	Else
		strMsg = "You do not have permission to delete the registry key value:" & vbCrLf & vbCrLf &_
			HKLM & "\" & aKey & "\" & aRegValName

		If blnVista Then
			strMsg = strMsg & vbCrLf & vbCrLf & "Check that UAC is disabled or set to prompt for approval."
		End If

		strMsg = strMsg & vbCrLf & vbCrLf & "Abort (exit the program), Retry (try this setting again), " &_
			"or Ignore (skip this setting for this device)?"

		result = MsgBox(strMsg, vbAbortRetryIgnore+vbExclamation, "Access Denied")

		Select Case result
			Case vbRetry
				DeleteRegValue aKey, aRegValName
			Case vbIgnore
				' Do nothing
			Case Else
				Call(Done)			
		End Select 
	End If
End Sub




