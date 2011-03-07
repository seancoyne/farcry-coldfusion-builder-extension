<cfcomponent output="false">
	
	<!--- getCurrentDir taken from varScoper Extension by Raymond Camden --->
	<cffunction name="getCurrentURL" output="No" access="public" returnType="string">
	    <cfset var theURL = getPageContext().getRequest().GetRequestUrl().toString()>
	    <cfif len( CGI.query_string )><cfset theURL = theURL & "?" & CGI.query_string></cfif>
	    <!--- Hack by Raymond, remove any CFID CFTOKEN --->
		<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cfid=[0-9]+", "")>
		<cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cftoken=[^&]+", "")>
	    <cfreturn theURL>
	</cffunction>
	
	<!--- getCurrentDir taken from varScoper Extension by Raymond Camden --->
	<cffunction name="getCurrentDir" output="No" access="public" returnType="string">
	    <cfset var theURL = getCurrentURL()>
		<cfset theURL = listDeleteAt(theURL, listLen(theURL, "/"), "/")>
		<cfreturn theURL>
	</cffunction>
	
	<cffunction name="determineFarCryVersion" output="false" access="public" returntype="struct">
		<cfargument name="pathToCore" type="string" required="true" />
		
		<cfset var stResult = { majorVersion = "", minorVersion = "", patchVersion = "" } />
		
		<cfif fileExists(arguments.pathToCore & "/major.version")>
			<cfset stResult.majorVersion = trim(fileRead(arguments.pathToCore & "/major.version")) />
		</cfif>
		
		<cfif fileExists(arguments.pathToCore & "/minor.version")>
			<cfset stResult.minorVersion = trim(fileRead(arguments.pathToCore & "/minor.version")) />
		</cfif>
		 
		<cfif fileExists(arguments.pathToCore & "/patch.version")>
			<cfset stResult.patchVersion = trim(fileRead(arguments.pathToCore & "/patch.version")) />
		</cfif>
		
		<cfreturn stResult />
		
	</cffunction>
	
	<cffunction name="parseFarCryProjectDirectoryName" output="false" access="public" returntype="string">
		<cfargument name="farCryConstructorContent" required="true" type="string" />
		<!--- first try this.projectdirectoryname --->
		<cfset var stMatches = reFindNoCase('this.projectDirectoryName[[:space:]]{1,}=[[:space:]]{1,}\"([^\"]*)\"',arguments.farCryConstructorContent,0,true) />
		<cfif arraylen(stMatches.len) eq 2>
			<cfreturn mid(arguments.farCryConstructorContent, stMatches.pos[2], stMatches.len[2]) />
		<cfelse>
			<!--- no this.projectdirectoryname, so try to find this.name --->
			<cfset stMatches = reFindNoCase('this.name[[:space:]]{1,}=[[:space:]]{1,}\"([^\"]*)\"',arguments.farCryConstructorContent,0,true) />
			<cfif arraylen(stMatches.len) eq 2>
				<cfreturn mid(arguments.farCryConstructorContent, stMatches.pos[2], stMatches.len[2]) />
			</cfif>
		</cfif>
		<cfreturn "" />
	</cffunction> 
	
	<cffunction name="cleanFileName" output="false" access="public" returntype="string">
		<cfargument name="str" required="true" type="string" />
		
		<cfreturn reReplaceNoCase(arguments.str,"[^0-9a-z]","-","ALL") />	
		
	</cffunction>
	
	<cffunction name="loadProjectConfig" output="false" access="public" returntype="struct">
		<cfargument name="projectname" type="string" required="true" />
		<cfargument name="configPath" type="string" required="true" />
		<cfif fileExists(arguments.configPath & "/" & cleanFileName(request.projectName) & ".json")>
			<cfset var projectConfig = trim(fileRead(arguments.configPath & "/" & application.oCustomFunctions.cleanFileName(request.projectName) & ".json")) />
			<cfif isJson(projectConfig)>
				<cfreturn deserializeJson(projectConfig) />
			</cfif>
		</cfif>
		<cfreturn {} />
	</cffunction>

	<cffunction name="checkFormError" output="false" returntype="string">
	  <cfargument name="key" type="string" required="true" hint="Struct key matching the error name to check for" />
	  
	  <cfset var returnStr = "" />
	  
	  <cfif structKeyExists(variables.stErrors, "#arguments.key#")>
	    <cfset returnStr = '<br /><div class="errorMsg">#variables.stErrors["#arguments.key#"]#</div>' />
	  </cfif>
	  
	  <cfreturn returnStr />
	</cffunction>

</cfcomponent>