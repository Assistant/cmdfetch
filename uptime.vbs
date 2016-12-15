strComputer = "."

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colOperatingSystems = objWMIService.ExecQuery _
    ("Select * from Win32_OperatingSystem")
 
For Each objOS in colOperatingSystems
    dtmBootup = objOS.LastBootUpTime 
    dtmLastBootupTime = WMIDateStringToDate(dtmBootup)
    dtmSystemUptime = DateDiff("n", dtmLastBootUpTime, Now)
Next

Function WMIDateStringToDate(dtmBootup)
  WMIDateStringToDate = _
  DateSerial(Left(dtmBootup, 4), _
    Mid(dtmBootup,  5, 2), Mid(dtmBootup,  7, 2) ) + _
  TimeSerial(Mid(dtmBootup,  9, 2),  _
    Mid(dtmBootup, 11, 2), Mid(dtmBootup, 13, 2) )
End Function

  dtmSystemUptime = DateDiff("n", dtmLastBootUpTime, Now)
  intDays = dtmSystemUptime \ 1440
  intHours = dtmSystemUptime \ 60 - 24 * intDays
  intMinutes = dtmSystemUptime Mod 60
  Wscript.Echo intDays & "d " & intHours & "h " & intMinutes & "m"