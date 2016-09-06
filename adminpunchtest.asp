<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>

<%

Response.buffer=true
' Do not allow caching on the browser (this in effect disallows back and forward button stuff:
     Response.CacheControl = "no-cache"
     Response.AddHeader "Pragma", "no-cache"
	 
MM_timecardasp_STRING = application("oConn")

 
 
if (len(session("SSN")) = 0 or session("MGR") = "None") then
	Response.Write "SSN length = 0"
	Response.Redirect ("Signon.asp")
end if

aCurrentSunday2 = session("CurrentStartPeriod")

if WeekDay(now()) <> 1  then											'Not Sunday 

	aDateDiff = (WeekDay(now()) - 1)  * -1
	aCurrentSundayp = dateadd("d", aDateDiff, now())

else

	aCurrentSundayp = now()	

end if

If Session("MGR")= "Administrator" Then
Dim PerSundays(6)					'change this number of back periods Admins can see
pers = 5							'set this one to one less
End If
If Session("MGR")= "Manager" Then
ReDim PerSundays(2)					'change this number of back periods Mgrs can see
pers = 1							'set this one to one less
End If
 											
for psundays = 0 to pers 					
PerSundays(psundays) = datevalue(dateadd("d", psundays * -7, aCurrentSundayp))
'response.write formatdatetime(PerSundays(psundays), vbShortdate)
'response.write pdays(pday)
next 


'If Request.Form("Edit")= "" and session("selected") = "no" then

'response.write "hi" & session("CurrentStartPeriod") & session("selected")
'end if
If Request.Form("selweek")<>"" then
session("CurrentStartPeriod") = Request.Form("selweek")
session("selected") = "yes"
response.redirect "adminpunchtest.asp"
'response.write "new date is" & session("CurrentStartPeriod") & session("selected")
end if

aCurrentSunday1 = aCurrentSunday2
'response.write "hi" & aCurrentSunday1
'variable declarations

punchtype = "NoAction"							'sets update button
aCurrentPday = formatdatetime(now(), vbShortdate)
aCurrentSunday = formatdatetime(aCurrentSunday1, vbShortdate)
aCurrentSundayuse = formatdatetime(aCurrentSunday1, vbShortdate)

currPunchday = Date
editOn = "off"									'sets edit screen option
Dim dateExists(7)								
Dim PayColumns(5)
PayColumns(0) = "TimeIn"
PayColumns(1) = "LunchOut"
PayColumns(2) = "LunchIn"
PayColumns(3) = "LunchOut2"
PayColumns(4) = "LunchIn2"
PayColumns(5) = "TimeOut"


dim pdays(6)									'array for week dates
for pday = 0 to 6
pdays(pday) = datevalue(dateadd("d", pday, aCurrentSunday1))
'response.write formatdatetime(pdays(pday), vbShortdate)
'response.write pdays(pday)
next

sunday = "Edit "&pdays(0)						'button date names
monday = "Edit "&pdays(1)
tuesday = "Edit "&pdays(2)
wednesday = "Edit "&pdays(3)
thursday = "Edit "&pdays(4)
friday = "Edit "&pdays(5)
saturday = "Edit "&pdays(6)


	aFirstName = Request.QueryString("Name")	'gets name of person's card
	aSSN = session("ApprovalEmp")				'gets session SSN
mSSN = session("SSN")
'response.write aSSN & " " & mSSN
aDateRetrievep = datevalue(aCurrentSundayuse)	
Dim afullcardAll(7,10)							'array for full week of timepunch
Dim afullcard(7,8)								'array for entered user time
Dim fullcard
Dim fullcard_cmd
Dim fullcard_numRows

Set fullcard_cmd = Server.CreateObject ("ADODB.Command")
fullcard_cmd.ActiveConnection = MM_timecardasp_STRING
fullcard_cmd.CommandText = "SELECT [Date], TimeIn, LunchOut, LunchIn, LunchOut2, LunchIn2, TimeOut, reason, SSN FROM dbo.tbltimepunchcard where" & _
"((dbo.tbltimepunchcard.SSN) ='" & aSSN & "') AND ((dbo.tbltimepunchcard.CurrTCDate)= '"& aDateRetrievep &"' ) ORDER BY [Date] ASC;"  
fullcard_cmd.Prepared = true

Set fullcard = fullcard_cmd.Execute
fullcard_numRows = 0

Dim Repeat1__numRows
Dim Repeat1__index

Repeat1__numRows = 7
Repeat1__index = 0
frows = 0
fullcard_numRows = fullcard_numRows + Repeat1__numRows

 While ((Repeat1__numRows <> 0) AND (NOT fullcard.EOF)) 					'collects entered users time into array
		afullcard(frows,0) = fullcard.Fields.Item("Date").Value
		afullcard(frows,1) = fullcard.Fields.Item("TimeIn").Value
		afullcard(frows,2) = fullcard.Fields.Item("LunchOut").Value
		afullcard(frows,3) = fullcard.Fields.Item("LunchIn").Value
		afullcard(frows,4) = fullcard.Fields.Item("LunchOut2").Value
		afullcard(frows,5) = fullcard.Fields.Item("LunchIn2").Value
		afullcard(frows,6) = fullcard.Fields.Item("TimeOut").Value
		afullcard(frows,7) = fullcard.Fields.Item("reason").Value
		frows = frows +1
  Repeat1__index=Repeat1__index+1
  Repeat1__numRows=Repeat1__numRows-1
  fullcard.MoveNext()
Wend

	If frows = 0 Then											'creates array of week including non-existant day entries 
		For wkpdays = 0 to 6									'also identifies if sql type to be update or insert
			afullcardAll(wkpdays,0) = "sInsert"
			afullcardAll(wkpdays,1) = pdays(wkpdays)
			afullcardAll(wkpdays,9) = aSSN
			For PayColumn = 0 to 6
				afullcardAll(wkpdays,paycolumn + 2) = ""
			Next
		Next
	End If
	
	If frows > 0 then
		fdays = 0
		For wkpdays = 0 to 6 
		
  IF afullcard(fdays,0) = pdays(wkpdays) then
			dateExists(wkpdays)= "yes"
			afullcardAll(wkpdays,0) = "sUpdate"
			afullcardAll(wkpdays,1) = pdays(wkpdays)
			afullcardAll(wkpdays,9) = aSSN
				For PayColumn = 1 to 7
					afullcardAll(wkpdays,paycolumn + 1) = afullcard(fdays,PayColumn)
				next
				fdays = fdays +1
		Else
			afullcardAll(wkpdays,0) = "sInsert"
			afullcardAll(wkpdays,1) = pdays(wkpdays)
			afullcardAll(wkpdays,9) = aSSN
			For PayColumn = 0 to 6
				afullcardAll(wkpdays,paycolumn + 2) = ""
			next
		End If
		next
	End If


Select Case Request.Form("Edit")					'button push on edit dates logic here - allows edit screen and correct day to edit
Case sunday
editOn = "on"
editDate = pdays(0)
eday = 0

Case monday
editOn = "on"
editDate = pdays(1)
eday = 1

Case tuesday
editOn = "on"
editDate = pdays(2)
eday = 2

Case wednesday
editOn = "on"
editDate = pdays(3)
eday = 3

Case thursday
editOn = "on"
editDate = pdays(4)
eday = 4

Case friday
editOn = "on"
editDate = pdays(5)
eday = 5

Case saturday
editOn = "on"
editDate = pdays(6)
eday = 6

End Select


select case Request.Form("submitedit")

case "timein"

noentry = ""
fcurdate=Request.Form("txtpDay1")
ftimein=Request.Form("txtpDay2")
flunchout=Request.Form("txtpDay3")
flunchin=Request.Form("txtpDay4")
flunchout2=Request.Form("txtpDay5")
flunchin2=Request.Form("txtpDay6")
ftimeout=Request.Form("txtpDay7")
ftcdate= aCurrentSundayuse
freason=Request.Form("selreason")

Dim schkrec
Dim schkrec_cmd
Dim schkrec_numRows
fcurdate=Request.Form("txtpDay1")

Set schkrec_cmd = Server.CreateObject ("ADODB.Command")
schkrec_cmd.ActiveConnection = MM_timecardasp_STRING
schkrec_cmd.CommandText = "SELECT [Date], SSN FROM dbo.tbltimepunchcard where" & _
"((dbo.tbltimepunchcard.SSN) ='" & aSSN & "') AND ((dbo.tbltimepunchcard.Date)= '"& fcurdate &"' ) ORDER BY [Date] ASC;"  
schkrec_cmd.Prepared = true

Set schkrec = schkrec_cmd.Execute
schkrec_numRows = 0

Dim sRepeat1__numRows
Dim sRepeat1__index

sRepeat1__numRows = 7
sRepeat1__index = 0
sfrows = 0
schkrec_numRows = schkrec_numRows + Repeat1__numRows

 If ((sRepeat1__numRows <> 0) AND (NOT schkrec.EOF)) Then


	Dim Sqpunchupdate
	Set Sqpunchupdate_cmd = Server.CreateObject ("ADODB.Command")
	Sqpunchupdate_cmd.ActiveConnection = MM_timecardasp_STRING
	Sqpunchupdate_cmd.CommandText = "Update dbo.tbltimepunchcard set TimeIn='"&ftimein&"',LunchOut='"& flunchout &"'"&_
	",LunchIn='"& flunchin &"', LunchOut2='"& flunchout2 &"', LunchIn2='"& flunchin2 &"', TimeOut='"& ftimeout &"',"&_
	" updatedby= '"& mSSN &"', tmchanged='"& now() &"', reason='"& freason &"' Where((dbo.tbltimepunchcard.SSN) ='" & aSSN & "')"&_
	" AND ((dbo.tbltimepunchcard.Date)= '"& fcurdate &"' )"
	Sqpunchupdate_cmd.CommandType = 1
	Sqpunchupdate_cmd.CommandTimeout = 0
	Sqpunchupdate_cmd.Prepared = true
	Sqpunchupdate_cmd.Execute()
	response.Redirect("adminpunchtest.asp?Action=Update")
	
else

	Dim Sqpunchedit
	Set Sqpunchedit_cmd = Server.CreateObject ("ADODB.Command")
	Sqpunchedit_cmd.ActiveConnection = MM_timecardasp_STRING
	Sqpunchedit_cmd.CommandText = "INSERT INTO dbo.tbltimepunchcard (SSN, CurrTCDate,"&_
	" Date, TimeIn, LunchOut, LunchIn, LunchOut2, LunchIn2, TimeOut, updatedby, reason, tmchanged)"&_  
	"VALUES ('" & aSSN & "','"&ftcdate&"','"&fcurdate&"','"&ftimein&"', '"& flunchout &"',"&_
	"'"& flunchin &"', '"& flunchout2 &"', '"& flunchin2 &"', '"& ftimeout &"', '"& mSSN &"', '"& freason &"', '"& now() &"') "
	Sqpunchedit_cmd.CommandType = 1
	Sqpunchedit_cmd.CommandTimeout = 0
	Sqpunchedit_cmd.Prepared = true
	Sqpunchedit_cmd.Execute()
	response.Redirect("adminpunchtest.asp?Action=Insert")
	'response.write ("1"&fcurdate&"2"&ftimein&"3"&flunchout&"4"&flunchin&"5"flunchout2&"6"&flunchin2&"7"&ftimein")
end if
	
	
end select

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>ADMINPUNCH</title>
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
.style50 {font-size: 24px; color: #3C41C1; font-weight: bold; }
-->
</style>

<script type="text/javascript">

function getClockTime() {
//get current time
var now    = new Date();
var hour   = 12;
var minute = 00;
var second = "00";
var ap = "PM";
if (hour   > 11) { ap = "PM";             }
if (hour   > 12) { hour = hour - 12;      }
if (hour   == 0) { hour = 12;             }
if (hour   < 10) { hour   = "0" + hour;   }
if (minute < 10) { minute = "0" + minute; }
//if (second < 10) { second = "0" + second; }
var timeString = hour + ':' + minute + ':' + second + " " + ap;
//var timeString = hour + ':' + minute + " " + ap;
document.getElementById("time").innerText=timeString;
}

function changetime(interval,direction) {
//chamge hours or minutes up or down
var currentdisplay =
document.getElementById('time').innerText.toUpperCase();
var times=currentdisplay.split(':');
var h_current = parseFloat(times[0]);          //hours
var m_current = parseFloat(times[1]);          //minutes
var len = currentdisplay.length;
var ap = currentdisplay.substring(len-2,len);  //AM or PM
var h_new=h_current;
var m_new=m_current;
if (interval=='ap') {
if (direction=='AM') ap='AM';
if (direction=='PM') ap='PM';
}
if (interval=='h') {
if (direction=='+') h_new += 1;
if (direction=='-') h_new -= 1;
}
if (interval=='m') {
if (direction=='+') m_new += 15;
if (direction=='-') m_new -= 15;
}

if (m_new > 59) {
m_new -= 60;
}
if (m_new < 0) {
m_new = 45;
}
if (h_new == 0) {
h_new=12;
}
if (h_new > 12) {
h_new -= 12;
}
if (h_new < 10)
h_new= '0' + h_new;
if (m_new < 10)
m_new = '0'+m_new;
var timeString = h_new + ':' + m_new + ':' + "00" +" " + ap;
document.getElementById("time").innerText=timeString;
return true;
}

function flipampm(ap) {
//swap am-pm
if (ap == 'AM')
ap='PM';
else
ap='AM';
return ap;
}


function editTime(btime) {
document.getElementById(btime).innerText=document.getElementById("time").innerText;
return; 
}

function clearTime(ctime) {
document.getElementById(ctime).innerText="";
return; 
}

</script>




<form id="form1" name="form1" method="post" />

<table width="1124" border="0" align="center">
 <p align="center"> <tr> <td colspan="3" align="center">
 
 <% If editOn <> "on" then%>											<%'added to fix display%>
<label><span class="style29">Edit Other Time Period</span>
       
	     <select  name="selweek" size="1" >
							<OPTION value=""></option>
							<%
							
								For psuns = 0 to pers 
									
										Response.Write "<OPTION "
										Response.write "value='" & PerSundays(psuns) & "'>" & PerSundays(psuns) &  "</OPTION>"
										
								next%>
						
          </select>
  </label>
		<input name="selperiod" type="submit"  id="selperiod"  value="Select" />
  
		<input name="timepunch2" type="button"  id="timepunch2" onClick="location.href='Supermenutest.asp'" value="Back to Switchboard" />
      </td>
      <% end if %>                                                     <%'added to fix display%>
  </tr>
  
</p>
  <tr>
    <td width="347"><img src="images/companyLogo.gif" width="325" height="101" /></td>
    <td width="396" align="center" valign="top">
      <p>&nbsp;</p>
      <p>
  <% If editOn = "on" then%>	
  
  <span class="style50">Edit Punchcard </span></p>
<div class="style11" id="time" name="time"></div>      
<table border="1" align="center" bgcolor="#CCCCCC">												<!--manual clock -->
<tr><td>Hours</td><td>Minutes</td><td>AM/PM</td></tr>
<tr><td><input type="button" value=" + " onclick="changetime('h','+')"></td>
<td><input type="button" value=" + " onclick="changetime('m','+')"></td>
<td><input type="button" value=" AM " onclick="changetime('ap','AM')"></td></tr>

<tr>
  <td><input type="button" value="  -  " onClick="changetime('h','-')"></td>
  <td><input type="button" value="  -  " onclick="changetime('m','-')"></td>
<td><input type="button" value=" PM " onclick="changetime('ap','PM')"></td></tr>
</table>

<p></p>
<%else%>
&nbsp;	
<%end if%>	</td>
    <td width="367">&nbsp;	</td>
  </tr>													
</table>
<%'depending on if an edit button is pushed edit screen will show or the week overview screen%>
<% If editOn = "on" then%>											
<p align="center"><strong><span class="style11">Select Button to Enter New Time for 
      <% response.write aFirstName %> on <%= afullcardAll(eday,1)%>
</span></strong></p>
<%else%>
<p align="center"><strong><span class="style11">Timecard Review for 
      <% response.write aFirstName %> 
  for the week of  
  <%response.write aCurrentSundayuse%>
</span></strong></p>
<table border="2" align="center" cellpadding="5" cellspacing="2" bordercolor="#3342BF">
  <tr>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">Date</span></td>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">TimeIn</span></td>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">LunchOut</span></td>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">LunchIn</span></td>
	<td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">LunchOut2</span></td>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">LunchIn2</span></td>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">TimeOut</span></td>
    <td align="center" valign="middle" class="style29"><span class="style48"><span class="style10">&nbsp;&nbsp;&nbsp;Reason &nbsp;&nbsp;&nbsp;</span></td>
  </tr>

 	<tr> 
 	<%											'builds table for overview
	If frows = 0 Then
		For wkpdays = 0 to 6%>
			<td align="center" valign="middle"><input name="edit" type="submit"  id= "button" value="Edit <%= pdays(wkpdays)%>" /></td>
			<%For PayColumn = 2 to 8%>
				<td align="center" valign="middle"><%="&nbsp"%></td>
			<%Next%>
  </tr>
		<%Next
	End If
	
	If frows > 0 then
		fdays = 0
		For wkpdays = 0 to 6 %>
		<%'response.write "paydays" & pdays(wkpdays) & "fullcard" &afullcard(wkpdays,0)%>
		
  		<%IF afullcard(fdays,0) = pdays(wkpdays) then%>
			<%dateExists(wkpdays)= "yes"%>
   			<td align="center" valign="middle"><input name="edit" type="submit"  id= "button" value="Edit <%= pdays(wkpdays)%>" /></td>
				<%For PayColumn = 1 to 7%>
					<td align="center" valign="middle"><%="&nbsp"& afullcard(fdays,PayColumn)%></td>
				<%next%></tr>
				<%fdays = fdays +1%>
		<%Else%>
			<td align="center" valign="middle"><input name="edit" type="submit"  id= "button" value="Edit <%= pdays(wkpdays)%>" /></td>
			<%For PayColumn = 2 to 8%>
				<td align="center" valign="middle"><%="&nbsp"%></td>
			<%next%></tr>
		<%End If%>
		<%next%>
	<%End If%>
	</tr></table>
<%end if%>

	
<% If editOn = "on" then			'this is the edit screen

%>	
<body onload="getClockTime()">					
<table border="2" align="center" cellpadding="5" cellspacing="2" bordercolor="#3342BF">
<tr>
  <td align="center" valign="middle" class="style29"><span class="style48">Date</td>
  <td align="center" valign="middle" class="style29"><span class="style48"><input name="ClearTIn" type="button" onClick="clearTime('txtpDay2')" id="ClearTIn"  value="Clear" /><input name="TimeIn" type="button" onClick="editTime('txtpDay2')" id="TimeIn"  value=" TimeIn " /></td>
  <td align="center" valign="middle" class="style29"><span class="style48"><input name="ClearTLOut" type="button" onClick="clearTime('txtpDay3')" id="ClearTLOut"  value="Clear" /><input name="LunchOut" type="button"  onClick="editTime('txtpDay3')" id="LunchOut"  value=" LunchOut " /></td>
  <td align="center" valign="middle" class="style29"><span class="style48"><input name="ClearTLIn" type="button" onClick="clearTime('txtpDay4')" id="ClearTLIn"  value="Clear" /><input name="LunchIn" type="button"  onClick="editTime('txtpDay4')" id="LunchIn"  value=" LunchIn " /></td>
  <td align="center" valign="middle" class="style29"><span class="style48"><input name="ClearTLOut2" type="button" onClick="clearTime('txtpDay5')" id="ClearTLOut2"  value="Clear" /><input name="LunchOut2" type="button"  onClick="editTime('txtpDay5')" id="LunchOut2"  value=" LunchOut2 " /></td>
  <td align="center" valign="middle" class="style29"><span class="style48"><input name="ClearTLIn2" type="button" onClick="clearTime('txtpDay6')" id="ClearTLIn2"  value="Clear" /><input name="LunchIn2" type="button"  onClick="editTime('txtpDay6')" id="LunchIn2"  value=" LunchIn2 " /></td>
  <td align="center" valign="middle" class="style29"><span class="style48"><input name="ClearTOut" type="button" onClick="clearTime('txtpDay7')" id="ClearTOut"  value="Clear" /><input name="TimeOut" type="button"  onClick="editTime('txtpDay7')" id="TimeOut"  value=" TimeOut " /></td>
</tr>
<tr>



<p align="center"> 
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay1" value = <%= afullcardAll(eday,1)%>></td>
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay2" value = <%="'"&afullcardAll(eday,2)&"'"%>></td>
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay3" value = <%="'"&afullcardAll(eday,3)&"'"%>></td>
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay4" value = <%="'"&afullcardAll(eday,4)&"'"%>></td>
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay5" value = <%="'"&afullcardAll(eday,5)&"'"%>></td>
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay6" value = <%="'"&afullcardAll(eday,6)&"'"%>></td>
<td align="center" valign="middle" class="style29"><input readonly type="text" name="txtpDay7" value = <%="'"&afullcardAll(eday,7)&"'"%>></td>
  </tr></table><input readonly type="hidden" name="txtpDay8" value = <%="'"&afullcardAll(eday,0)&"'"%>>
		 
          </p>
<p align="center">
          <label><span class="style29">Reason</span>
          <select name="selreason" size="1">
            <option value="Employee Forgot">Employee Forgot</option>
            <option value="Unavailable">Unavailable</option>
            <option value="Un-Authorized Overtime">Un-Authorized Overtime</option>
            <option value="Offsite">Offsite</option>
          </select>
  </label>
 <input name="submitedit" type="submit"  id="submitedit"  value=" Submit " />&nbsp;
 <input name="resetedit" type="reset"  id="resetedit"  value=" Reset " />&nbsp;
  <input name="Back" type="button"  id="Back"  value=" Back " onClick="location.href='adminpunchtest.asp'" />

</p>  
 
       
  <%end if%>
  </head>
</form>
<script language="vbscript">
sub insertedit
	'msgbox("Change " & " 1 " & form1.txtpDay1.value &" 2 "& form1.txtpDay2.value & " 3 " & form1.txtpDay3.value& " 4 " & form1.txtpDay4.value& " 5 " & form1.txtpDay5.value& " 6 " & form1.txtpDay6.value& " 7 " & form1.txtpDay7.value& " rea " &form1.selreason.value)'

End Sub

Function form1_onsubmit()
If form1.txtpDay7.value <>"" and (form1.txtpDay6.value <>"" or form1.txtpDay5.value <>"") then
	IF form1.txtpDay5.value <> "" and form1.txtpDay6.value <> "" then
		IF form1.txtpDay2.value <> "" and form1.txtpDay3.value <> "" and form1.txtpDay4.value<> "" Then
		 	IF TimeValue(form1.txtpDay7.value) > TimeValue(form1.txtpDay6.value) and TimeValue(form1.txtpDay6.value) > TimeValue(form1.txtpDay5.value) and TimeValue(form1.txtpDay5.value) > TimeValue(form1.txtpDay4.value) and TimeValue(form1.txtpDay4.value) > TimeValue(form1.txtpDay3.value) and TimeValue(form1.txtpDay3.value) > TimeValue(form1.txtpDay2.value) then
			msgBox("Time Entered is ok")
			call insertedit
			form1.submitedit.value = "timein"
			Else
			msgBox("Time Entered is later than a later period.")
			form1_onsubmit = false
			END IF
		Else
		MsgBox("You have not entered in values for TimeIn, LunchOut or LunchIn.")
		form1_onsubmit = false
		End If
	Else
	MsgBox("You have not entered in values for LunchOut2 or LunchIn2.")
	form1_onsubmit = false
	End If
End If

If form1.txtpDay7.value <>"" and form1.txtpDay6.value ="" and form1.txtpDay5.value ="" then
	IF form1.txtpDay2.value <> "" and form1.txtpDay3.value <> "" and form1.txtpDay4.value<> "" Then
		IF TimeValue(form1.txtpDay7.value) > TimeValue(form1.txtpDay4.value) and TimeValue(form1.txtpDay4.value) > TimeValue(form1.txtpDay3.value) and TimeValue(form1.txtpDay3.value) > TimeValue(form1.txtpDay2.value) then
		msgBox("Time Entered is ok")
		call insertedit
		form1.submitedit.value = "timein"
		Else
		msgBox("Time Entered is later than a later period.")
		form1_onsubmit = false
		END IF
	Else
	MsgBox("You have not entered in values for TimeIn, LunchOut or LunchIn.")
	form1_onsubmit = false
	End If
End If

If form1.txtpDay6.value <>"" and form1.txtpDay7.value ="" then
	IF form1.txtpDay2.value <> "" and form1.txtpDay3.value <> "" and form1.txtpDay4.value<> "" and form1.txtpDay5.value<> "" Then
		IF TimeValue(form1.txtpDay6.value) > TimeValue(form1.txtpDay5.value) and TimeValue(form1.txtpDay5.value) > TimeValue(form1.txtpDay4.value) and TimeValue(form1.txtpDay4.value) > TimeValue(form1.txtpDay3.value) and TimeValue(form1.txtpDay3.value) > TimeValue(form1.txtpDay2.value) then
		msgBox("Time Entered is ok")
		call insertedit
		form1.submitedit.value = "timein"
		Else
		msgBox("Time Entered is later than a later period.")
		form1_onsubmit = false
		END IF
	Else
	MsgBox("You have not entered in values for TimeIn, LunchOut, LunchIn or LunchOut2.")
	form1_onsubmit = false
	End If
End If

If form1.txtpDay5.value <>"" and form1.txtpDay7.value ="" and form1.txtpDay6.value ="" then
	IF form1.txtpDay2.value <> "" and form1.txtpDay3.value <> "" and form1.txtpDay4.value<> "" Then
		IF TimeValue(form1.txtpDay5.value) > TimeValue(form1.txtpDay4.value) and TimeValue(form1.txtpDay4.value) > TimeValue(form1.txtpDay3.value) and TimeValue(form1.txtpDay3.value) > TimeValue(form1.txtpDay2.value) then
		msgBox("Time Entered is ok")
		call insertedit
		form1.submitedit.value = "timein"
		Else
		msgBox("Time Entered is later than a later period.")
		form1_onsubmit = false
		END IF
	Else
	MsgBox("You have not entered in values for TimeIn, LunchOut or LunchIn.")
	form1_onsubmit = false
	End If
End If

If form1.txtpDay4.value <>"" and form1.txtpDay7.value ="" and form1.txtpDay6.value ="" and form1.txtpDay5.value ="" then
	IF form1.txtpDay2.value <> "" and form1.txtpDay3.value <> "" Then
		IF TimeValue(form1.txtpDay4.value) > TimeValue(form1.txtpDay3.value) and TimeValue(form1.txtpDay3.value) > TimeValue(form1.txtpDay2.value) then
		msgBox("Time Entered is ok")
		call insertedit
		form1.submitedit.value = "timein"
		Else
		msgBox("Time Entered is later than a later period.")
		form1_onsubmit = false
		END IF
	Else
	MsgBox("You have not entered in values for TimeIn or LunchOut.")
	form1_onsubmit = false
	End If
End If

If form1.txtpDay3.value <>"" and form1.txtpDay7.value ="" and form1.txtpDay6.value ="" and form1.txtpDay5.value ="" and form1.txtpDay4.value ="" then
	IF form1.txtpDay2.value <> "" Then
		IF  TimeValue(form1.txtpDay3.value) > TimeValue(form1.txtpDay2.value) then
		msgBox("Time Entered is ok")
		call insertedit
		form1.submitedit.value = "timein"
		Else
		msgBox("Time Entered is later than a later period.")
		form1_onsubmit = false
		END IF
	Else
	MsgBox("You have not entered in values for TimeIn.")
	form1_onsubmit = false
	End If
End If

If form1.txtpDay2.value <>"" and form1.txtpDay7.value ="" and form1.txtpDay6.value ="" and form1.txtpDay5.value ="" and form1.txtpDay4.value ="" and form1.txtpDay3.value ="" then
	msgBox("Time Entered is ok")
	call insertedit
	form1.submitedit.value = "timein"
ElseIf form1.txtpDay2.value ="" and form1.txtpDay7.value ="" and form1.txtpDay6.value ="" and form1.txtpDay5.value ="" and form1.txtpDay4.value ="" and form1.txtpDay3.value ="" Then
	If form1.txtpDay8.value ="sUpdate" then
		msgBox("Time Entered is ok")
		call insertedit
		form1.submitedit.value = "timein"
	Else
		msgBox("You have not entered any time.")
		form1_onsubmit = false
	End If
END IF

End function
</script>



<p>&nbsp;</p>
</body>
</html>
<%
fullcard.Close()
Set fullcard = Nothing
%>