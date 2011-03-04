<cfsetting enablecfoutputonly="true" />

<cfparam name="attributes.bIncludeHeaderFooter" default="true" type="boolean" />
<cfparam name="attributes.workbench" default="" />
<cfparam name="attributes.title" default="" />
<!--- dialog attributes - (http://help.adobe.com/en_US/ColdFusionBuilder/Using/WS0ef8c004658c1089-54e5d346121ed44b434-8000.html#WS0ef8c004658c1089-185affce121ed5c17e0-8000) --->
<cfparam name="attributes.width" default="" />
<cfparam name="attributes.height" default="" />
<cfparam name="attributes.image" default="" />
<cfparam name="attributes.dialogclosehandler" default="" />
<!---  view attributes --->
<cfparam name="attributes.id" default="" /> <!--- Required for views --->
<cfparam name="attributes.icon" default="" />
<cfparam name="attributes.handlerid" default="" /> 

<!--- Validation --->
<cfif attributes.workbench eq "view" and attibutes.id eq "">
  <cfthrow message="When workbench is view, and id is required" />
</cfif>

<cfif thisTag.executionMode eq "start">
  <cfif attributes.workbench neq "">
    <cfcontent reset="true" type="application/xml" />
    <cfheader name="Content-Type" value="text/xml" />
    <cfoutput><response status="success" showresponse="true">
    <ide>
    <cfif attributes.workbench eq "dialog">
      <dialog<cfif attributes.width neq ""> width="#attributes.width#"</cfif><cfif attributes.height neq ""> height="#attributes.height#"</cfif><cfif attributes.title neq ""> title="#attributes.title#"</cfif><cfif attributes.image neq ""> image="#attributes.image#"</cfif><cfif attributes.dialogclosehandler neq ""> dialogclosehandler="#attributes.dialogclosehandler#"</cfif>
      <dialog width="#attributes.width#" height="#attributes.height#" title="#attributes.title#" />
    <cfelseif attibutes.workbench eq "view">
      <view id="#attributes.id#"<cfif attributes.title neq ""> title="#attributes.title#"</cfif><cfif attributes.icon neq ""> icon="#attributes.icon#"</cfif><cfif attributes.handlerid neq ""> handlerid="#attributes.handlerid#"</cfif> />
    </cfif>
      <body>
        <![CDATA[</cfoutput>
  </cfif>
  <cfif attributes.bIncludeHeaderFooter is true>
    <cfmodule template="#application.oCustomFunctions.getCurrentDir()#/tags/webskin/header.cfm" pageTitle="#attributes.title#" />
  </cfif>
<cfelse>
  <cfif attributes.workbench neq "">
    <cfoutput>
        ]]>
      </body>
    </ide>
		</response></cfoutput>
  </cfif>
  <cfif attributes.bIncludeHeaderFooter is true>
    <cfmodule template="#application.oCustomFunctions.getCurrentDir()#/tags/webskin/footer.cfm" />
  </cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />