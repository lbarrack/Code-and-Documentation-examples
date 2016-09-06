<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>

<%
	MM_timecardasp_STRING = application("oConn")
	
	Response.Buffer=true
' Do not allow caching on the browser (this in effect disallows back and forward button stuff:
     Response.CacheControl = "no-cache"
     Response.AddHeader "Pragma", "no-cache"


if len(session("SSN")) = 0 then
	Response.Redirect ("Signon.asp")
end if
vTimeIn = "no"

strTest = ""
if WeekDay(now()) <> 1  then											'Not Sunday 

	aDateDiff = (WeekDay(now()) - 1)  * -1
	aCurrentSunday = dateadd("d", aDateDiff, now())

else

	aCurrentSunday = now()	

end if

dim pdays(14)
aCurrentSunday=dateadd("d", -7, aCurrentSunday)
for pday = 0 to 13
pdays(pday) = datevalue(dateadd("d", pday, aCurrentSunday))
'response.write formatdatetime(pdays(pday), vbShortdate)
next

punchtype = "NoAction"
lunch2b = "Inactive"
v2ndLunch = "No Action"
aCurrentPday = formatdatetime(now(), vbShortdate)
aCurrentSundayuse = formatdatetime(aCurrentSunday, vbShortdate)
aPassedDate = aCurrentSunday
currPunchday = Date
aSSN = session("SSN")
aDateRetrievep1 = datevalue(formatdatetime(pdays(0), vbShortdate))
aDateRetrievep2 = datevalue(formatdatetime(pdays(7), vbShortdate))
aDateRetrievep = datevalue(formatdatetime(pdays(13), vbShortdate))

Dim afullcard(14,7)
Dim fullcard
Dim fullcard_cmd
Dim fullcard_numRows

Set fullcard_cmd = Server.CreateObject ("ADODB.Command")
fullcard_cmd.ActiveConnection = MM_timecardasp_STRING
fullcard_cmd.CommandText = "SELECT [Date], TimeIn, LunchOut, LunchIn, TimeOut, LunchOut2, LunchIn2, SSN"&_
" FROM dbo.tbltimepunchcard where" & _
"((dbo.tbltimepunchcard.SSN) ='" & aSSN & "') AND ((dbo.tbltimepunchcard.Date)"&_
"Between '"& aDateRetrievep1 &"'  AND '"& aDateRetrievep &"' ) ORDER BY [Date] ASC;"  
fullcard_cmd.Prepared = true

Set fullcard = fullcard_cmd.Execute
fullcard_numRows = 0

Dim Repeat1__numRows
Dim Repeat1__index

Repeat1__numRows = 14
Repeat1__index = 0
frows = 0
fullcard_numRows = fullcard_numRows + Repeat1__numRows

 While ((Repeat1__numRows <> 0) AND (NOT fullcard.EOF)) 
		afullcard(frows,0) = fullcard.Fields.Item("Date").Value
		afullcard(frows,1) = fullcard.Fields.Item("TimeIn").Value
		afullcard(frows,2) = fullcard.Fields.Item("LunchOut").Value
		afullcard(frows,3) = fullcard.Fields.Item("LunchIn").Value
		afullcard(frows,4) = fullcard.Fields.Item("LunchOut2").Value
		afullcard(frows,5) = fullcard.Fields.Item("LunchIn2").Value
		afullcard(frows,6) = fullcard.Fields.Item("TimeOut").Value
		frows = frows +1
		'response.write fullcard.Fields.Item("Date").Value
  Repeat1__index=Repeat1__index+1
  Repeat1__numRows=Repeat1__numRows-1
  fullcard.MoveNext()
Wend



Dim currentpunch
Dim currentpunch_cmd
Dim currentpunch_numRows

Set currentpunch_cmd = Server.CreateObject ("ADODB.Command")
currentpunch_cmd.ActiveConnection = MM_timecardasp_STRING
currentpunch_cmd.CommandText = "SELECT Date, TimeIn, LunchOut, LunchIn, TimeOut, LunchOut2, LunchIn2 FROM dbo.VIEWpunchtimetoday"&_
" where((dbo.VIEWpunchtimetoday.SSN) ='" & aSSN & "')"
currentpunch_cmd.Prepared = true

Set currentpunch = currentpunch_cmd.Execute
currentpunch_numRows = 0

Dim Repeat2__numRows
Dim Repeat2__index

Repeat2__numRows = 1
Repeat2__index = 0
currentpunch_numRows = currentpunch_numRows + Repeat2__numRows

If Request.Form("timepunch") = "LunchOut" Then
  clockpunch = Time()
  noentry = ""
	Set sqlLunchOut = Server.CreateObject ("ADODB.Command")
	sqlLunchOut.ActiveConnection = MM_timecardasp_STRING
	sqlLunchOut.CommandText = "update dbo.tbltimepunchcard SET LunchOut = '" & clockpunch & "'  WHERE SSN='" & aSSN & "' and "&_
	"Date = '"& currPunchday &"' "
	sqlLunchOut.CommandType = 1
	sqlLunchOut.CommandTimeout = 0
	sqlLunchOut.Prepared = true
	sqlLunchOut.Execute()
	response.Redirect("punchcardtest.asp?Action=Update")
End If

If Request.Form("timepunch") = "LunchIn" Then
  clockpunch = Time()
  noentry = ""
	Set sqlLunchIn = Server.CreateObject ("ADODB.Command")
	sqlLunchIn.ActiveConnection = MM_timecardasp_STRING
	sqlLunchIn.CommandText = "update dbo.tbltimepunchcard SET LunchIn = '" & clockpunch & "'  WHERE SSN='" & aSSN & "' and "&_
	"Date = '"& currPunchday &"' "
	sqlLunchIn.CommandType = 1
	sqlLunchIn.CommandTimeout = 0
	sqlLunchIn.Prepared = true
	sqlLunchIn.Execute()
	response.Redirect("punchcardtest.asp?Action=Update")
End If

If Request.Form("timepunch") = "TimeOut" Then
  clockpunch = Time()
  noentry = ""
	Set sqlTimeOut = Server.CreateObject ("ADODB.Command")
	sqlTimeOut.ActiveConnection = MM_timecardasp_STRING
	sqlTimeOut.CommandText = "update dbo.tbltimepunchcard SET TimeOut = '" & clockpunch & "'  WHERE SSN='" & aSSN & "' and "&_
	"Date = '"& currPunchday &"' "
	sqlTimeOut.CommandType = 1
	sqlTimeOut.CommandTimeout = 0
	sqlTimeOut.Prepared = true
	sqlTimeOut.Execute()
	response.Redirect("punchcardtest.asp?Action=Update")
End If
	
If Request.Form("timepunch") = "TimeIn" then
	If ((Repeat2__numRows <> 0) AND (NOT currentpunch.EOF)) then
		vTimeIn = "" 
		clockpunch = Time()
	  	noentry = ""
		Set sqlTimeOut = Server.CreateObject ("ADODB.Command")
		sqlTimeOut.ActiveConnection = MM_timecardasp_STRING
		sqlTimeOut.CommandText = "update dbo.tbltimepunchcard SET TimeIn = '" & clockpunch & "'  WHERE SSN='" & aSSN & "' and "&_
		"Date = '"& currPunchday &"' "
		sqlTimeOut.CommandType = 1
		sqlTimeOut.CommandTimeout = 0
		sqlTimeOut.Prepared = true
		sqlTimeOut.Execute()
		response.Redirect("punchcardtest.asp?Action=Update")
	else
		
	  	clockpunch = Time()
	  	noentry = ""
		set sqlTimeIn = Server.CreateObject ("ADODB.Command")
		sqlTimeIn.ActiveConnection = MM_timecardasp_STRING
		sqlTimeIn.CommandText = "INSERT INTO dbo.tbltimepunchcard (SSN, CurrTCDate,"&_
		" TimeIn, Date, LunchOut, LunchIn, LunchOut2, LunchIn2, TimeOut, updatedby)"&_  
		"VALUES ('" & aSSN & "','"& aDateRetrievep2 &"','"& clockpunch &"','"& currPunchday &"', '"& noentry &"',"&_
		"'"& noentry &"', '"& noentry &"', '"& noentry &"', '"& noentry &"', '"& noentry &"') "
		sqlTimeIn.CommandType = 1
		sqlTimeIn.CommandTimeout = 0
		sqlTimeIn.Prepared = true
		sqlTimeIn.Execute()
		response.Redirect("punchcardtest.asp?Action=Insert")
	End If
End If
	

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>TIMEPUNCH</title>
<link href="_Themes/pstmdrn/color0.css" rel="stylesheet" type="text/css" />
<link href="_Themes/pstmdrn/theme.css" rel="stylesheet" type="text/css" media="all" />
<style type="text/css">
<!--
.style11 {
	font-size: 18pt;
	color: #1A27B4;
}
-->
</style>
<link href="css/skyetimestyle.css" rel="stylesheet" type="text/css" />
<style type="text/css">
<!--
.style29 {font-size: 18px; color: #3C41C1; }
.style50 {font-size: 18px; color: #CCCCCC; }
.style57 {font-size: small}
.style58 {font-size: small; color: #3C41C1; }
.style59 {font-size: x-small}
.style60 {font-size: x-small; color: #3C41C1; }
.style61 {
	font-size: xx-small;
	font-weight: bold;
}
-->
</style>

<script type="text/JavaScript">
<!--
//-->
</script>


</head>
<body>
<form id="form1" name="form1" method="post" />


<table width="1124" border="0" align="center">
  <tr>
    <td width="325"><img src="images/companyLogo.gif" width="325" height="101" /></td>
    <td width="418" align="center" valign="top"><input name="timepunch2" type="button"  id="timepunch2" onclick="location.href='timecardtest.asp'" value="Back to Timecard" /></td>
    <td width="367">&nbsp;</td>
  </tr>
</table>
<p align="center" class="style11"><strong>Current Time is <%=time()%></strong></p>
<p align="center"><strong><span class="style11">Timecard for <% response.write session ("Name") %> for the weeks of  <%response.write aDateRetrievep1 & " And " & aDateRetrievep2%></span></strong></p>

<table border="2" align="center" cellpadding="5" cellspacing="2" bordercolor="#3342BF"><td>
<table border="2" align="center" cellpadding="5" cellspacing="2" bordercolor="#3342BF">
  <tr>
    <td align="center" valign="middle" class="style59 style29"><span class="style61"><span class="style48">Date</span></td>
    <td align="center" valign="middle" class="style59 style58"><span class="style61"><span class="style48">TimeIn</span></td>
    <td align="center" valign="middle" class="style59 style58"><span class="style61"><span class="style48">LunchOut</span></td>
    <td align="center" valign="middle" class="style59 style58"><span class="style61"><span class="style48">LunchIn</span></td>
	<td align="center" valign="middle" class="style59 style58"><span class="style61"><span class="style48">LunchOut2</span></td>
    <td align="center" valign="middle" class="style59 style58"><span class="style61"><span class="style48">LunchIn2</span></td>
    <td align="center" valign="middle" class="style59 style58"><span class="style61"><span class="style48">TimeOut</span></td>
  </tr>
 <tr> 
 	<%
	If frows = 0 Then
		For wkpdays = 0 to 6%>
			
			<td align="center" valign="middle"><span class="style57">
			  <% = pdays(wkpdays)%>
			</span></td>
			<%For PayColumn = 0 to 5%>
				<td align="center" valign="middle"><span class="style57"><%="&nbsp"%></span></td>
			<%Next%>
  </tr>
		<%Next
	End If
	
	If frows > 0 then
		fdays = 0
		For wkpdays = 0 to 6 %>
		<%'response.write "paydays" & pdays(wkpdays) & "fullcard" &afullcard(fdays,0)%>
	
  		<%IF afullcard(fdays,0) = pdays(wkpdays) then%>
   			<td align="center" valign="middle"><span class="style57"><%="&nbsp"&afullcard(fdays,0)%></span></td>
				<%For PayColumn = 1 to 6%>
					<td align="center" valign="middle"><span class="style57"><%="&nbsp"& afullcard(fdays,PayColumn)%></span></td>
				<%next%></tr>
				<%fdays = fdays +1%>
		<%Else%>
			<td align="center" valign="middle"><span class="style57"><%="&nbsp"& pdays(wkpdays)%></span></td>
			<%For PayColumn = 0 to 5%>
				<td align="center" valign="middle"><span class="style57"><%="&nbsp"%></span></td>
			<%next%></tr>
		<%End If%>
		<%next%>
	<%End If%>
	</tr></table></td>
<td>
	<table border="2" align="center" cellpadding="5" cellspacing="2" bordercolor="#3342BF">
  <tr>
    <td align="center" valign="middle" class="style59 style29"><span class="style61"><span class="style48">Date</span></td>
    <td align="center" valign="middle" class="style60"><span class="style61"><span class="style48">&nbsp;&nbsp;TimeIn&nbsp;&nbsp;</span></td>
    <td align="center" valign="middle" class="style60"><span class="style61"><span class="style48">&nbsp;&nbsp;LunchOut&nbsp;&nbsp;</span></td>
    <td align="center" valign="middle" class="style60"><span class="style61"><span class="style48">&nbsp;&nbsp;LunchIn&nbsp;&nbsp;</span></td>
	<td align="center" valign="middle" class="style60"><span class="style61"><span class="style48">&nbsp;&nbsp;LunchOut2&nbsp;&nbsp;</span></td>
    <td align="center" valign="middle" class="style60"><span class="style61"><span class="style48">&nbsp;&nbsp;LunchIn2&nbsp;&nbsp;</span></td>
    <td align="center" valign="middle" class="style60"><span class="style61"><span class="style48">&nbsp;&nbsp;TimeOut&nbsp;&nbsp;</span></td>
  </tr>
 <tr> 
 	<%
	If frows = 0 Then
		For wkpdays = 7 to 13%>
			
			<td align="center" valign="middle"><span class="style57">
		    <% = pdays(wkpdays)%>
			</span></td>
			<%For PayColumn = 0 to 5%>
				<td align="center" valign="middle"><span class="style57"><%="&nbsp"%></span></td>
			<%Next%>
  </tr>
		<%Next
	End If
	
	If frows > 0 then
		For wkpdays = 7 to 13 %>
		<%'response.write "paydays" & pdays(wkpdays) & "fullcard" &afullcard(fdays,0)& "fdays "&fdays%>
	
  		<%IF afullcard(fdays,0) = pdays(wkpdays) then%>
   			<td align="center" valign="middle"><span class="style57"><%="&nbsp"&afullcard(fdays,0)%></span></td>
				<%For PayColumn = 1 to 6%>
					<td align="center" valign="middle"><span class="style57"><%="&nbsp"& afullcard(fdays,PayColumn)%></span></td>
				<%next%></tr>
				<%fdays = fdays +1%>
		<%Else%>
			<td align="center" valign="middle"><span class="style57"><%="&nbsp"& pdays(wkpdays)%></span></td>
			<%For PayColumn = 0 to 5%>
				<td align="center" valign="middle"><span class="style57"><%="&nbsp"%></span></td>
			<%next%></tr>
		<%End If%>
		
		<%next%>
	<%End If%>
	</tr></table></td>
</table>
<p>&nbsp;</p>
<table border="3" align="center" cellpadding="3" cellspacing="3" bordercolor="#3342BF">
  <tr>
    <td colspan="7" align="center" valign="middle" class="style11">Time Punch  For Today </td>
  </tr>
  <tr>
    <td align="center" valign="middle"><span class="style29">Date</span></td>
    <td align="center" valign="middle" class="style50"><span class="style29">TimeIn</span></td>
    <td align="center" valign="middle"><span class="style29">LunchOut</span></td>
    <td align="center" valign="middle"><span class="style29">LunchIn</span></td>
	<td align="center" valign="middle"><span class="style50">LunchOut2</span></td>
    <td align="center" valign="middle"><span class="style50">LunchIn2</span></td>
    <td align="center" valign="middle"><span class="style29">TimeOut</span></td>
  </tr>
  
  <% While ((Repeat2__numRows <> 0) AND (NOT currentpunch.EOF)) %>
  <tr>
    <td align="center" valign="middle"><%=("&nbsp"&currentpunch.Fields.Item("Date").Value)%></span></td>
    <td align="center" valign="middle"><%=("&nbsp"&currentpunch.Fields.Item("TimeIn").Value)%></span></td>
	<%vTimeIn=currentpunch.Fields.Item("TimeIn").Value%>
    <td align="center" valign="middle"><%=("&nbsp"&currentpunch.Fields.Item("LunchOut").Value)%></span></td>
	<%vLunchOut=currentpunch.Fields.Item("LunchOut").Value%>
    <td align="center" valign="middle"><%=("&nbsp"&currentpunch.Fields.Item("LunchIn").Value)%></span></td>
	<%vLunchIn=currentpunch.Fields.Item("LunchIn").Value%>
	<td align="center" valign="middle" class="style50"><%=("&nbsp"&currentpunch.Fields.Item("LunchOut2").Value)%></span></td>
	<%vLunchOut2=currentpunch.Fields.Item("LunchOut2").Value%>
    <td align="center" valign="middle" class="style50"><%=("&nbsp"&currentpunch.Fields.Item("LunchIn2").Value)%></span></td>
	<%vLunchIn2=currentpunch.Fields.Item("LunchIn2").Value%>
    <td align="center" valign="middle"><%=("&nbsp"&currentpunch.Fields.Item("TimeOut").Value)%></span></td>
	<%vTimeOut=currentpunch.Fields.Item("TimeOut").Value%>
  </tr>

  <% 
  Repeat2__index=Repeat2__index
  Repeat2__numRows=Repeat2__numRows-1
  'currentpunch.MoveNext()
  
Wend
  if  Repeat2__numRows = 1 then %>
    <tr>
    <td align="center" valign="middle"><%= Date%></td>
    <td align="center" valign="middle" class="style50"><%="&nbsp&nbsp&nbsp&nbsp"%></td>
    <td align="center" valign="middle"><%="&nbsp&nbsp&nbsp&nbsp"%></td>
   	<td align="center" valign="middle"><%="&nbsp&nbsp&nbsp&nbsp"%></td>
    <td align="center" valign="middle"class="style50"><%="&nbsp&nbsp&nbsp&nbsp"%></td>
	<td align="center" valign="middle"class="style50"><%="&nbsp&nbsp&nbsp&nbsp"%></td>
    <td align="center" valign="middle"><%="&nbsp&nbsp&nbsp&nbsp"%></td>

  <% 
  punchtype = "TimeIn"

  end if %>
  </tr
%>
</table>

<%	
if vTimeIn = "" then 
	punchtype = "TimeIn" 
end if
If punchtype <> "TimeIn" Then
	If vLunchOut="" then 
	punchtype = "LunchOut"
	'response.write "punchout"& punchtype
	ElseIf vLunchIn="" and punchtype <> "TimeIn" then
	punchtype = "LunchIn"
	'response.write "punchout"& punchtype
	ElseIf vTimeOut="" and punchtype <> "TimeIn" then
	punchtype = "TimeOut"
	'response.write "punchout"& punchtype
	End If
End If
if punchtype = "TimeOut" AND  (NOT currentpunch.EOF) Then
	if currentpunch.Fields.Item("LunchIn2").Value = "" then
	lunch2b = "active"
	v2ndLunch = "Enable 2nd Lunch"	
	end if
end if
If punchtype = "TimeOut" AND vLunchOut2 <> "" OR vLunchOut2 <> "" Then
response.redirect "punchcard2ndtest.asp"
end if
'response.write "hitbutton"&buttonhit&v2ndLunch
%>
<p align="center">
  <input name="timepunch" type="Submit"  id="timepunch" value="<%=punchtype%>" />
  <input name="timepunch2" type="button"  id="timepunch2" onClick="location.href='timecardtest.asp'" value="Back to Timecard" />
	<input name="2lunch" type="button" id="2lunch"<%if lunch2b="Inactive"then%> disabled <%end If%> onClick="location.href='punchcard2ndtest.asp'"value="Enable Lunch 2" />
</p>
<br />
  <br /> 
</form>
</body>
</html>
<%
currentpunch.Close()
Set currentpunch = Nothing
%>
