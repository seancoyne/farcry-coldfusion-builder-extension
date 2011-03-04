<cfsetting enablecfoutputonly="true" showdebugoutput="false" />



<cfif structKeyExists(form,"bHandleForm")>
	
	<cfset configData = {} />
	
	<cfparam name="form.pathToCore" default="" type="string" />
	<cfparam name="form.farCryVersion" default="" type="string" />
	<cfparam name="form.installationType" default="" type="string" />
	<cfparam name="form.projectName" default="" type="string" />
	
	<cfif not len(trim(form.projectName))>
		<!--- TODO: pretty error handling would be nice :) --->
		<cfthrow type="unknownProjectName" message="Unknown Project Name!" />
	</cfif>
	
	<cfset configData["pathToCore"] = form.pathToCore />
	<cfset configData["farCryVersion"] = form.farCryVersion />
	<cfset configData["installationType"] = form.installationType />
	
	<cfset jsonData = serializeJson(configData) />
	
	<cfset configPath = expandPath('../config/projects') />
	
	<!--- TODO: clean up the project name so it is safe to save as a file name --->
	<cfset fileName = reReplaceNoCase(form.projectName,"[^0-9a-z]","-","ALL") />	
	
	<cffile action="write" file="#configPath#/#fileName#.json" output="#trim(jsonData)#" addnewline="false" />
	
	<!--- TODO: better output --->
	<cfoutput><h1>Hey it worked!</h1></cfoutput>
	
</cfif>

<cfif structKeyExists(form,"ideEventInfo")>
	<!--- TODO: check for json file first --->
	
	<cfset configData = { pathToCore = "", installationType = "", farCryVersionShort = "", farCryVersionFull = "" } />
	
	<cfset ideInfo = xmlParse(form.ideEventInfo) />
	
	<cfset projectName = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectname"] />
	<cfset projectLocation = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectLocation"] />
	<cfif directoryExists(projectLocation & "/farcry/core")>
		
		<!--- Try to detect FarCry core location --->
		
		<cfset configData.pathToCore = projectLocation & "/farcry/core" />
		<cfset configData.installationType = "subdirectory" />
		
		<cfif fileExists(configData.pathToCore & "/major.version")>
			<cfset majorVersion = fileRead(configData.pathToCore & "/major.version") />
		<cfelse>
			<cfset majorVersion = "" />
		</cfif>
		
		<cfif fileExists(configData.pathToCore & "/minor.version")>
			<cfset minorVersion = fileRead(configData.pathToCore & "/minor.version") />
		<cfelse>
			<cfset minorVersion = "" />
		</cfif>
		 
		<cfif fileExists(configData.pathToCore & "/patch.version")>
			<cfset patchVersion = fileRead(configData.pathToCore & "/patch.version") />
		<cfelse>
			<cfset patchVersion = "" />
		</cfif>
		
		<cfset configData.farCryVersionFull = majorVersion & "." & minorVersion & "." & patchVersion />
		<cfset configData.farCryVersionShort = majorVersion & "." & minorVersion & ".x" />
		
	<cfelse>
		<cfset configData.installationType = "advanced" />
	</cfif>
	
	<cfoutput>
		<form action="#application.oCustomFunctions.getCurrentUrl()#" method="post">
			
			<label for="pathToCore">Path to FarCry core:</label>
			<input type="text" name="pathToCore" id="pathToCore" value="#configData.pathToCore#" />
			<br />
			
			<label for="installationType">Installation Type:</label>
			<input type="radio" name="installationType" id="installationType_subdirectory" value="subdirectory" <cfif configData.installationType eq "subdirectory">checked="checked"</cfif> />
			<label for="installationType_subdirectory">Standalone/Subdirectory</label>
			<input type="radio" name="installationType" id="installationType_advanced" value="advanced" <cfif configData.installationType eq "advanced">checked="checked"</cfif> />
			<label for="installationType_advanced">Advanced</label>
			<br />
			
			<label for="farCryVersion">FarCry Version:</label>
			<select name="farCryVersion" id="farCryVersion">
				<option value="6.0.x" <cfif configData.farCryVersionShort eq "6.0.x">selected="selected"</cfif>>6.0.x</option>
				<option value="6.1.x" <cfif configData.farCryVersionShort eq "6.1.x">selected="selected"</cfif>>6.1.x</option>
			</select>
			<br />
			
			<input type="hidden" name="projectName" value="#projectName#" />
			<input type="hidden" name="bHandleForm" value="1" />
			
			<button type="submit">Submit</button>
			
		</form>	
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false" />