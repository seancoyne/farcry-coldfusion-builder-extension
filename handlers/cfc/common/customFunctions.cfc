<cfcomponent output="true">
	
	<!--- getCurrentURL taken from varScoper Extension by Raymond Camden --->
	<cffunction name="getCurrentURL" output="false" access="public" returnType="string">
    <cfset var theURL = getPageContext().getRequest().GetRequestUrl().toString() />
    <cfif len( CGI.query_string )><cfset theURL = theURL & "?" & CGI.query_string /></cfif>
    <!--- Hack by Raymond, remove any CFID CFTOKEN --->
    <cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cfid=[0-9]+", "") />
    <cfset theUrl = reReplaceNoCase(theUrl, "[&?]*cftoken=[^&]+", "") />
    <cfreturn theURL />
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
		<cfset var stMatches = reFindNoCase('this.projectDirectoryName[[:space:]]{0,}=[[:space:]]{0,}\"([^\"]*)\"',arguments.farCryConstructorContent,0,true) />
		<cfif arraylen(stMatches.len) eq 2>
			<cfreturn mid(arguments.farCryConstructorContent, stMatches.pos[2], stMatches.len[2]) />
		<cfelse>
			<!--- no this.projectdirectoryname, so try to find this.name --->
			<cfset stMatches = reFindNoCase('this.name[[:space:]]{0,}=[[:space:]]{0,}\"([^\"]*)\"',arguments.farCryConstructorContent,0,true) />
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
	
  <cffunction name="loadExtensionConfig" output="false" access="public" returntype="struct">
    <cfset var stReturn = {} />
    <cfset var currentDir = replace(getCurrentDir(), "\", "/", "all") /><!--- Clean paths for Windows users --->
    <cfset var xmlFile = trim(listDeleteAt(currentDir, listLen(currentDir, "/"), "/") & "/ide_config.xml") />

    <cfif fileExists(xmlFile)>
      <cfset var extensionConfigXml = fileRead(xmlFile) />
      <cfif isXml(extensionConfigXml)>
        <cfset stReturn.oXml = xmlParse(extensionConfigXml) />
        <cfset stReturn.name = stReturn.oXml["application"]["name"]["xmlText"] />
        <cfset stReturn.author = stReturn.oXml["application"]["author"]["xmlText"] />
        <cfset stReturn.email = stReturn.oXml["application"]["email"]["xmlText"] />
        <cfset stReturn.version = stReturn.oXml["application"]["version"]["xmlText"] />
      </cfif>
    </cfif>

    <cfreturn stReturn />
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
	
	<cffunction name="getInputValue" output="false" returntype="string" access="public">
		<cfargument name="xml" type="xml" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="default" type="string" required="false" default="" />
		<cfset var searchResult = xmlSearch(arguments.xml, "/event/user/input[@name='#arguments.name#']") />
		<cfif arrayLen(searchResult)>
			<cfreturn searchResult[1].xmlAttributes.value />
		</cfif> 
		<cfreturn arguments.default />
	</cffunction>
	
	<cffunction name="addPluginToList" output="false" returntype="string" access="public">
		<cfargument name="farCryConstructorContent" required="true" type="string" />
		<cfargument name="pluginName" required="true" type="string" />
		<cfset var regEx = 'this.plugins[[:space:]]{0,}=[[:space:]]{0,}\"([^\"]*)\"' />
		<cfset var stMatches = reFindNoCase(regEx,arguments.farCryConstructorContent,0,true) />
		<cfif arrayLen(stMatches.len) eq 2>
			<cfset var pluginList = mid(arguments.farCryConstructorContent, stMatches.pos[2], stMatches.len[2]) />
			<cfif not listFindNoCase(pluginList,arguments.pluginName)>
				<cfset pluginList = listAppend(pluginList,arguments.pluginName) />
			</cfif>
			<cfreturn reReplaceNoCase(arguments.farCryConstructorContent,regEx,'this.plugins = "' & pluginList & '"') />
		</cfif>
		<cfreturn arguments.farCryConstructorContent />
	</cffunction> 

	<!--- author: Steve Parks (steve@adeptdeveloper.com). version 1, May 20, 2005 --->
	<cffunction name="millisecondsToDate" access="public" output="false" returnType="date">
		<cfargument name="strMilliseconds" type="string" required="true" />
		<cfreturn dateAdd("s", strMilliseconds/1000, "january 1 1970 00:00:00") />
	</cffunction>

</cfcomponent>