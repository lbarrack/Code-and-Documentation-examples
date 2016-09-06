<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<% 
on error resume next 

Dim strDomain 
Dim strADsPath 
Dim strUserName 
Dim strPassword 
Dim iFlags
Dim errorcount
oConn = Application("oConn")

if WeekDay(now()) <> 1  then											'Not Sunday 

	aDateDiff = (WeekDay(now()) - 1)  * -1
	aCurrentSunday = dateadd("d", aDateDiff, now())

else

	aCurrentSunday = now()	

end if

'variable declarations

session("punchSunday") = formatdatetime(aCurrentSunday, vbShortdate)


errorcount = 0

' force the domain
'if Request.Form("Domain") <> "company" then
     'strDomain = Request.Form("Domain")
     'if strDomain = "" then strDomain = "company" end if
'else
     strDomain = "company"
'end if

strADsPath = strDomain 
iFlags = Request.Form("Flags") 
strPassword = Request.Form("Password") 
strUserName = Request.Form("UserName") 

%>                
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<style type="text/css">
<!--
.style1 {color: #0055A5}
-->
</style>
<title>company Timecard</title><body background="images/sumtextb.jpg">
<form action = "Signon.asp" method = "post" id=form1 name=form1>
                  <p>&nbsp;</p>
                  <table border="0" align="center">
                    <tr>
                      <td><img src="images/companyLogo.gif" alt="" width="325" height="101" /></td>
                      <td align="left"></td>
                    </tr>
                    <tr>
                      <td colspan="2" align="center"><p>&nbsp;</p>
                          <h3 class="style1">Electronic Timecard System</h3>
                        </p></td>
                    </tr>
                  </table>
                  <p>&nbsp;</p>
                  <table width="347" border="2" align="center" cellpadding="1" cellspacing="1">
                    <tr>
                      <th width="90" scope="col"><font color="#0055A5" class="news1"><strong>Login:</strong></font></th>
                      <th width="242" scope="col"><input name="UserName" type="text" id="UserName2" value="<%response.write strUserName%>" size="40" /></th>
                    </tr>
                    <tr>
                      <td><div align="center"><font class="news1"><strong><font color="#0055A5">Password</font></strong></font><font color="#0055A5"><strong>:</strong></font></div></td>
                      <td><input type="password" id="Password2" name="Password" size = "40" /></td>
                    </tr>
                  </table>
                  <p align="center"><font color="#0055A5"><strong>Please Login with your Windows Login and Password</strong></font></p>
                  <p>&nbsp;</p>
<table width="100%" cellpadding="0" class=news1>
                    <tr valign="top"> 
                      <td width="97%" height="24"> <div align="center"> 
                          <p>
                            <input type="hidden" id=Flags2 name=Flags size = 10 value = 0>
                            <input type="submit" value="  Login  " id=submit12 name=submit1>
                            <input type="reset" name="Reset" value="  Reset  "onclick="JavaScript:location.href='Signonnew.asp'">
                          </p>
                          <p>
                             <input type="button" value="Back to Homepage" onclick="JavaScript:location.href='http://skyenet'" id="button1" name="button1" />
</p>
                      </div></td>
                    </tr>
                  </table>
</form>

<% 


if (not strUserName= "") then 

      strADsPath = "WinNT://" & strADsPath 
      Dim oADsObject  
      Dim tempstr 
      tempstr = strDomain & "\" & strUserName 

  
      Set oADsObject = GetObject(strADsPath) 

      Dim strADsNamespace 
      Dim oADsNamespace 
      strADsNamespace = left(strADsPath, instr(strADsPath, ":")) 
      set oADsNamespace = GetObject(strADsNamespace) 
      Set oADsObject = oADsNamespace.OpenDSObject(strADsPath, tempstr, strPassword, 0) 
     
           if not (Err.number = 0) then 
		   
                                             
               Response.Write "<p align=""center""><font color=""#0055A5""><strong> You did not enter the correct password<br> or login.<br>Please try again.</strong></p>" 
                 'response.write err.description & "<p>" 
               if err.number = -2147022987 then ' for account logout
                    Response.write "<strong>Your account has been locked out!</strong>"
                end if
         
          else 
 
            Session("USER_LOGIN") = strUserName
           Session("isLoggedIn") = True
           Session("ValidUser") = True
            set oDB = Server.CreateObject("ADODB.Connection")

			set oRS = Server.CreateObject("ADODB.Recordset")



			'vSQL = "SELECT * FROM TblEmployeeProfile WHERE SSN = '" & aSSn &"';"

			vSQL = "SELECT TblEmployeeProfile.SSN, TblEmployeeProfile.FirstName," & _

			" TblEmployeeProfile.LastName, TblEmployeeProfile.TimecardMgrID," & _

			" TblEmployeeProfile.PayType, TblEmployeeProfile.TimecardApprov, TblEmployeeProfile.DepartmentCode," & _

			" TblEmployeeProfile.status, tblassistant.ssn AS SuprSSN," & _

			" tblassistant.status AS AssistStatus FROM TblEmployeeProfile LEFT JOIN tblassistant" & _

			" ON TblEmployeeProfile.SSN = tblassistant.assn" & _

			" WHERE (TblEmployeeProfile.Login = '" & strUserName  & "');"



			'response.write vsql & "<BR>"



			oDB.Open oConn 

			oRS.Open vSQL, oDb

			Session("SSN") = oRs.Fields("SSN")

				Session("MGR") = oRs.Fields("TimecardApprov")
				Session("MGRP") = oRs.Fields("TimecardApprov")

				Session("Name") = oRS.Fields("FirstName")

				Session("aType") = oRS.Fields("PayType") 'added to see if timepunchcard needs session var
				Session("DepartmentCode") = oRS.Fields("DepartmentCode") 'used to test for specific group

				aType = oRS.Fields("PayType")

				'Response.Write session("MGR")

				'used later to display personal information

				'set now to logged on user

				

				signedup = true

				ors.Close

				odb.Close

				set odb = nothing

				set ors = nothing

				if Session("MGR") <> "None" then
					If Session("DepartmentCode")<>"931" then 'excludes it
						Response.Redirect ("supermenu.asp")
					else
						Response.Redirect ("supermenutest.asp") 'remove test to restore
					end if

				else	
						If Session("DepartmentCode")<>"931" then 'excludes it
							Response.Redirect ("timecard.asp")	
						else
							Response.Redirect ("timecardtest.asp") 'remeove test to restore
						end if

				end if	
			

			end if

			end if


                    

%>
