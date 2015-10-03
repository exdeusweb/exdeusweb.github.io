' 
' ATI HD Registry Tweaks for Maximum HTPC Performance
'
' Author: 	ExDeus		exdeus at comcast dot net
' Website:	http://home.comcast.net/~exdeus/ati-hd2x00/
' Date: 	2008-04-16
' Version:	0.14
'
' Suports Windows Vista, XP & MCE. 
' 
' This script is designed to add values to the Windows registry.
' Changing anything in the registry can be hazardous.
' No warranty is offered or implied. Use at your own risk!
' 
' This script will add a number of registry tweaks to enhance the 
' performance of ATI HD2000 & HD3000 series video cards for use in HTPCs. 
'
' Double-click to run.
'
' You will be prompted to approve the correct video device before 
' anything in the registry is changed. To add settings for multiple
' devices, simply re-run the program and select a different device.
' In Windows XP / MCE, the registry tweaks will be applied to all outputs,
' e.g., 0000 and 0001. In Windows Vista, the registry tweaks are applied
' uniformly to the active device, which applies to all outputs on that
' device.
'
' See http://home.comcast.net/~exdeus/ati-hd2x00/ for this program's home page.
'
'
' See http://www.avsforum.com/avs-vb/showpost.php?p=11622510&postcount=2011
' for details on the registry settings.
'
' See http://www.avsforum.com/avs-vb/showpost.php?p=11659897&postcount=2121
' for details on the effects of each setting.
'


'On Error Resume Next

const HKEY_LOCAL_MACHINE = &H80000002
const KEY_QUERY_VALUE = &H0001
const KEY_SET_VALUE = &H0002
const KEY_CREATE_SUB_KEY = &H0004
const DELETE = &H00010000
const REG_SZ = 1
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
	Array("DXVA_DetailEnhance", "0"),_
	Array("DXVA_NOHDDECODE", "0"),_
	Array("DXVA_Only24FPS1080MPEG2", "0"),_
	Array("DXVA_Only24FPS1080H264", "0"),_
	Array("DXVA_Only24FPS1080VC1", "0"),_
	Array("DXVA_WMV_NA", "0"),_
	Array("HWUVD_ForceMPEG2", "1"),_
	Array("SORTOverrideFPSCaps", "0"),_
	Array("SORTOverrideVidSizeCaps", "2800000")  ,_
	Array("TrDenoise", "0"),_
	Array("UseBT601CSC", "1"),_
	Array("VForce24FPS1080MPEG2", "0"),_
	Array("VForce24FPS1080H264", "0"),_
	Array("VForce24FPS1080VC1", "0"),_
	Array("VForceMaxResSize", "2800000"),_
	Array("VForceUVDVC1", "1"),_
	Array("VForceUVDH264", "1")_
)

Dim arr2600RegKeys 
arr2600RegKeys = Array(_
	Array("ColorVibrance_DEF", "0"),_
	Array("ColorVibrance_DE_MIN", "0"),_
	Array("ColorVibrance_NA", "0"),_
	Array("DI_METHOD", "5"),_
	Array("DI_METHOD_DEF", "5"),_
	Array("DXVA_DetailEnhance", "0"),_
	Array("DXVA_NOHDDECODE", "0"),_
	Array("DXVA_WMV_NA", "0"),_
	Array("Fleshtone_DEF", "0"),_
	Array("Fleshtone_DE_MIN", "0"),_
	Array("Fleshtone_NA", "0"),_
	Array("HWUVD_ForceMPEG2", "1"),_
	Array("SORTOverrideVidSizeCaps", "2800000"),_
	Array("TrDenoise", "0"),_
	Array("UseBT601CSC", "1"),_
	Array("VForceMaxResSize", "2800000"),_
	Array("VForceUVDVC1", "1"),_
	Array("VForceUVDH264", "1")_
)

Set objShell = CreateObject("WScript.Shell")
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
Set objOS = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colOperatingSystems = objOS.ExecQuery("Select * from Win32_OperatingSystem")


For Each objItem in colOperatingSystems   
    If InStr(1, objItem.Caption, "Vista", 1) Then
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
	

	result = MsgBox("Do you have the HD2400?" & vbCrLf & vbCrLf & "Answer 'No' for the HD2600 or HD3000 series.",_
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
			Else ' HD2600 or HD3000
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
					result = MsgBox("Add " & arr2400RegKey(0) & " = " & arr2400RegKey(1) & " ?",_
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
			Else ' HD2600 or HD3000
				For Each arr2600RegKey In arr2600RegKeys
					result = MsgBox("Add " & arr2600RegKey(0) & " = " & arr2600RegKey(1) & " ?",_
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
			Else ' HD2600 or HD3000
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
							
							result = MsgBox("Delete " & strVistaKey & strVideoDevice & VISTA_DXVA & "\" & arr2400RegKey(0) & " = " & strRegVal & " ?",_
								vbYesNo+vbQuestion, "Delete This RegValue?")

							If result = vbYes Then
								DeleteRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2400RegKey(0)
							End If
						Next
					Else
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVideoGUID & strVideoDevice, arr2400RegKey(0))
							
							result = MsgBox("Delete " & strVideoGUID & strVideoDevice & "\" & arr2400RegKey(0) & " = " & strRegVal & " ?",_
								vbYesNo+vbQuestion, "Delete This RegValue?")

							If result = vbYes Then
								DeleteRegValue strVideoGUID & strVideoDevice, arr2400RegKey(0)
							End If
						Next
					End If
				Next
			Else ' HD2600 or HD3000
				For Each arr2600RegKey In arr2600RegKeys
					If blnVista Then
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0))
							
							If Not IsNull(strRegVal) Then
								result = MsgBox("Delete " & strVistaKey & strVideoDevice & VISTA_DXVA & "\" & arr2600RegKey(0) & " = " & strRegVal & " ?",_
									vbYesNo+vbQuestion, "Delete This RegValue?")

								If result = vbYes Then
									DeleteRegValue strVistaKey & strVideoDevice & VISTA_DXVA, arr2600RegKey(0)
								End If
							End If
						Next
					Else
						For Each strVideoDevice In arrVideoDevices
							strRegVal = ReadRegValue(strVideoGUID & strVideoDevice, arr2600RegKey(0))
							
							If Not IsNull(strRegVal) Then
								result = MsgBox("Delete " & strVideoGUID & strVideoDevice & "\" & arr2600RegKey(0) & " = " & strRegVal & " ?",_
									vbYesNo+vbQuestion, "Delete This RegValue?")

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
	Else ' HD2600 or HD3000
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




