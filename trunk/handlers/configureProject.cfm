<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

<cfimport taglib="tags/webskin" prefix="skin" />

<cfif structKeyExists(form,"bHandleForm")>
	
	<cfset configData = {} />
	
	<cfparam name="form.pathToFarCry" default="" type="string" />
	<cfparam name="form.farCryVersion" default="" type="string" />
	<cfparam name="form.installationType" default="" type="string" />
	<cfparam name="form.projectName" default="" type="string" />
	<cfparam name="form.farCryProjectDirectoryName" default="" type="string" />
	
	<cfif not len(trim(form.projectName))>
		<!--- TODO: pretty error handling would be nice :) --->
		<cfthrow type="unknownProjectName" message="Unknown Project Name!" />
	</cfif>
	
	<cfset configData["paths"] = {} />
	<cfset configData["paths"]["FarCry"] = form.pathToFarCry />
	<cfset configData["paths"]["Core"] = form.pathToFarCry & "/core" />
	<cfset configData["paths"]["Plugins"] = form.pathToFarCry & "/plugins" />
	<cfset configData["paths"]["Projects"] = form.pathToFarCry & "/projects" />
	<cfset configData["farCryVersion"] = form.farCryVersion />
	<cfset configData["installationType"] = form.installationType />
	<cfif form.installationType eq "subdirectory">
		<cfset configData["farCryProjectDirectoryName"] = "" />
	<cfelse>
		<cfset configData["farCryProjectDirectoryName"] = form.farCryProjectDirectoryName />
	</cfif>
	
	<!--- save the configuration data --->
	<cfset jsonData = serializeJson(configData) />
	<cfset configPath = expandPath('../config/projects') />
	
	<!--- clean up the project name so it is safe to save as a file name --->
	<cfset fileName = application.oCustomFunctions.cleanFileName(form.projectname) />
	<cffile action="write" file="#configPath#/#fileName#.json" output="#trim(jsonData)#" addnewline="false" />
	
	<!--- TODO: better output --->
	<cfoutput><h1>Project has been configured</h1></cfoutput>
	
</cfif>

<cfif structKeyExists(form,"ideEventInfo") and not structKeyExists(form,"bHandleForm")>
	<!--- TODO: check for json file first --->
	
	<cfset ideInfo = xmlParse(form.ideEventInfo) />
		
	<cfset projectName = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectname"] />
	<cfset projectLocation = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectLocation"] />

	<cfif structKeyExists(request,"projectConfig")>
		
		<cfset configData = request.projectConfig />
		
		<cfset configData.pathToFarCry = configData.paths.farcry />
		<cfset configData.farCryVersionShort = configData.farCryVersion />
		<cfset configData.farCryVersionFull = "" />
		
	<cfelse>
		
		<cfset configData = { 
			pathToFarCry = "", 
			installationType = "", 
			farCryVersionShort = "", 
			farCryVersionFull = "", 
			farCryProjectDirectoryName = "" 
		} />
		
		
		
		<cfif directoryExists(projectLocation & "/farcry")>
			
			<!--- Try to detect FarCry core location --->
			
			<cfset configData.pathToFarCry = projectLocation & "/farcry" />
			<cfset configData.pathToCore = projectLocation & "/farcry/core" />
			
			<!--- determine the FarCry version number --->
			<cfset stFarCryVersion = application.oCustomFunctions.determineFarCryVersion(configData.pathToCore) />
			<cfif len(stFarCryVersion.majorVersion)>
				<cfset configData.farCryVersionFull = stFarCryVersion.majorVersion & "." & stFarCryVersion.minorVersion & "." & stFarCryVersion.patchVersion />
				<cfset configData.farCryVersionShort = stFarCryVersion.majorVersion & "." & stFarCryVersion.minorVersion & ".x" />
			</cfif>
			
			<!--- check for farcryConstructor in project root.  if found, its a standalone install, try to load projectDirectoryName --->
			<cfif fileExists(projectLocation & "/farcryConstructor.cfm")>
				
				<!--- this is a standalone installation --->
				<cfset configData.installationType = "standalone" />
				
				<!--- try to parse the project directory name from the farcry constructor --->
				<cfset farCryConstructorContent = fileRead(projectLocation & "/farcryConstructor.cfm") />
				<cfset configData.farCryProjectDirectoryName = application.oCustomFunctions.parseFarCryProjectDirectoryName(farCryConstructorContent) />
				
			<cfelse>
				
				<!--- this is probably a subdirectory installation --->
				
				<cfset configData.installationType = "subdirectory" />
	
			</cfif>
			
		<cfelse>
			
			<!--- this is most likely an advanced install --->
			<cfset configData.installationType = "advanced" />
			
			<!--- check for farcryConstructor in www folder, if found, try to load projectDirectoryName --->
			<cfif fileExists(projectLocation & "/www/farcryConstructor.cfm")>
				<cfset farCryConstructorContent = fileRead(projectLocation & "/www/farcryConstructor.cfm") />
				<cfset configData.farCryProjectDirectoryName = application.oCustomFunctions.parseFarCryProjectDirectoryName(farCryConstructorContent) />
			</cfif>
			
			<!--- try to determine the path to farcry --->
			<cfset tempLocation = reverse(listRest(reverse(projectLocation),"/\")) />
			<cfset tempLocation = reverse(listRest(reverse(tempLocation),"/\")) />
	
			<cfif directoryExists(tempLocation)>
				<cfset configData.pathToFarCry = tempLocation />
				<cfif directoryExists(configData.pathToFarCry & "/core")>
					<cfset stFarCryVersion = application.oCustomFunctions.determineFarCryVersion(configData.pathToFarCry & "/core") />
					<cfif len(stFarCryVersion.majorVersion)>
						<cfset configData.farCryVersionFull = stFarCryVersion.majorVersion & "." & stFarCryVersion.minorVersion & "." & stFarCryVersion.patchVersion />
						<cfset configData.farCryVersionShort = stFarCryVersion.majorVersion & "." & stFarCryVersion.minorVersion & ".x" />
					</cfif>
				</cfif>
			</cfif>
			
		</cfif>
	
	</cfif>	

	<skin:contentWrapperMain workbench="dialog" title="Configure Project" width="800" height="600">
	
	<cfoutput>
		
		<script type="text/javascript">
			$(document).ready(function(){
				
			});
		</script>
				
		<form action="#application.oCustomFunctions.getCurrentUrl()#" method="post">
			
			<label for="installationType">Installation Type:</label>
			<input type="radio" name="installationType" id="installationType_standalone" value="standalone" <cfif configData.installationType eq "standalone">checked="checked"</cfif> />
			<label for="installationType_standalone">Standalone</label>
			<input type="radio" name="installationType" id="installationType_subdirectory" value="subdirectory" <cfif configData.installationType eq "subdirectory">checked="checked"</cfif> />
			<label for="installationType_subdirectory">Subdirectory</label>
			<input type="radio" name="installationType" id="installationType_advanced" value="advanced" <cfif configData.installationType eq "advanced">checked="checked"</cfif> />
			<label for="installationType_advanced">Advanced</label>
			<br />
			
			<label for="farCryProjectDirectoryName">FarCry Project Directory Name:</label>
			<input type="text" name="farCryProjectDirectoryName" id="farCryProjectDirectoryName" value="#configData.farCryProjectDirectoryName#" />
			<br />
					
			<label for="pathToFarCry">Path to FarCry Folder:</label>
			<input type="text" name="pathToFarCry" id="pathToFarCry" value="#configData.pathToFarCry#" />
			<br />
			
			<label for="farCryVersion">FarCry Version:</label>
			<select name="farCryVersion" id="farCryVersion">
				<option value="6.0.x" <cfif configData.farCryVersionShort eq "6.0.x">selected="selected"</cfif>>6.0.x</option>
				<option value="6.1.x" <cfif configData.farCryVersionShort eq "6.1.x">selected="selected"</cfif>>6.1.x</option>
			</select>
			<br />
			
			<input type="hidden" name="ideEventInfo" value="#htmlEditFormat(form.ideEventInfo)#" />
			<input type="hidden" name="projectName" value="#projectName#" />
			<input type="hidden" name="bHandleForm" value="1" />
			
			<button type="submit">Submit</button>
			
		</form>	
	</cfoutput>
	
	</skin:contentWrapperMain>

</cfif>


<cfsetting enablecfoutputonly="false" />