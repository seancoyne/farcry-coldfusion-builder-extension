<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

<!--- list of all valid url commands for the page --->
<cfset lCommands = "formPage,actionPage,completePage" />

<!--- By default we assume we want the form --->
<cfset command = "formPage" />

<cfif structKeyExists(form,'cmd') AND listFindNoCase(lCommands,form.cmd)>
  <cfset command = form.cmd />
<cfelseif structKeyExists(url,'cmd') AND listFindNoCase(lCommands,url.cmd)>
  <cfset command = url.cmd />
</cfif>

<!--- Loop until we are done --->
<cfloop condition="true">
  <!--- 
    By default we will loop only once. 
    This variable can be reset by any of 
    the case statements to run another 
    loop iteration and run a different
    case statement by modifying variables.command --->
  <cfset variables.break = true />

  <cfswitch expression="#variables.command#">
    <cfcase value="formPage">
      <cfinclude template="includes/imageResize/imageResizeForm.cfm">
    </cfcase>
    <cfcase value="actionPage">
      <cfinclude template="includes/imageResize/imageResizeFormAction.cfm">
    </cfcase>
    <cfcase value="completePage">
      <cfinclude template="includes/imageResize/imageResizeFormComplete.cfm">
    </cfcase>
    <cfdefaultcase>
      <cfoutput><p>Invalid command (#variables.command#) encountered.</p></cfoutput>
    </cfdefaultcase>
  </cfswitch>

  <!--- Break out of the loop if necessary --->
  <cfif variables.break>
    <cfbreak />
  </cfif>
</cfloop>

<cfsetting enablecfoutputonly="false" />