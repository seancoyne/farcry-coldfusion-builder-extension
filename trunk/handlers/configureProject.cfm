<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

<cfimport taglib="tags/webskin" prefix="skin" />

<cfset handlerName = "configureProject" />

<cfif structKeyExists(variables, "command") is true or structKeyExists(form, "cmd") is true or structKeyExists(url, "cmd") is true>
  <cfset variables.workbench = "" />
<cfelse>
  <cfset variables.workbench = "dialog" />
</cfif>

<!--- list of all valid url commands for the page --->
<cfset lCommands = "formPage,actionPage,completePage" />

<!--- By default we assume we want the form --->
<cfset command = "formPage" />

<cfif structKeyExists(form,'cmd') AND listFindNoCase(lCommands,form.cmd)>
  <cfset command = form.cmd />
<cfelseif structKeyExists(url,'cmd') AND listFindNoCase(lCommands,url.cmd)>
  <cfset command = url.cmd />
</cfif>

<skin:contentWrapperMain workbench="#workbench#" title="Configure Project" width="800" height="650">

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
      <cfinclude template="includes/#handlerName#/#handlerName#Form.cfm">
    </cfcase>
    <cfcase value="actionPage">
      <cfinclude template="includes/#handlerName#/#handlerName#FormAction.cfm">
      <cfset variables.break = false />
    </cfcase>
    <cfcase value="completePage">
      <cfinclude template="includes/#handlerName#/#handlerName#FormComplete.cfm">
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

</skin:contentWrapperMain>

<cfsetting enablecfoutputonly="false" />