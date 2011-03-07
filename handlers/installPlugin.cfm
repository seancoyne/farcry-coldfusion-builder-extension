<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

<cfset ideXml = xmlParse(form.ideEventInfo) />

<cfif structKeyExists(ideXml["event"]["user"],"input")>
	
	<cfset searchResult = xmlSearch(ideXml, "/event/user/input[@name='pluginName']") />
	<cfif arrayLen(searchResult)>
		<cfset pluginName = searchResult[1].xmlAttributes.value />
	<cfelse>
		<cfset pluginName = "" />
	</cfif> 
	
	<cfset searchResult = xmlSearch(ideXml, "/event/user/input[@name='pathToPluginSource']") />
	<cfif arrayLen(searchResult)>
		<cfset pathToPluginSource = searchResult[1].xmlAttributes.value />
	<cfelse>
		<cfset pathToPluginSource = "" />
	</cfif> 
	
	<cfset searchResult = xmlSearch(ideXml, "/event/user/input[@name='bCopyFilesToWebroot']") />
	<cfif arrayLen(searchResult)>
		<cfset bCopyFilesToWebroot = searchResult[1].xmlAttributes.value />
	<cfelse>
		<cfset bCopyFilesToWebroot = false />
	</cfif> 
	
	<!--- TODO: ensure we have the plugin name and the path to the source files --->
	
	<cfset pathToManifest = "" />
	
	<cfif listLast(pathToPluginSource,".") eq "zip">
		
		<!--- unzip the file to the ram drive --->
		
		<cfif not directoryExists("ram://farCryCFBExtension/")>
			<cfset directoryCreate("ram://farCryCFBExtension/") />
		</cfif>
		
		<cfset unzipDir = "ram://farCryCFBExtension/" & application.oCustomFunctions.cleanFileName(listLast(pathToPluginSource,"\/")) />
		
		<cfif not directoryExists(unzipDir)>
			<cfset directoryCreate(unzipDir) />
		</cfif>
		
		<cfzip action="unzip" destination="#unzipDir#" file="#pathToPluginSource#" overwrite="true" />
		
		<!--- find the manifest file --->
		<cfdirectory directory="#unzipDir#" recurse="true" action="list" name="qFiles" filter="manifest.cfc" />
		<cfif qFiles.recordCount>
			<cfset pathToManifest = qfiles.directory[1] & "/" & qfiles.name[1] />
		</cfif>
		
	<cfelseif listLast(pathToPluginSource,"/\") eq "manifest.cfc">
		<cfset pathToManifest = pathToPluginSource />
	</cfif>
	
	<cfif not len(pathToManifest)>
		<cfset status = "error" />
		<cfset message = "Invalid file selected.  You must select a zip file or manifest.cfc file." />
	<cfelse>
		
		<!--- determine the base folder path --->	
		<cfset basePath = getDirectoryFromPath(pathToManifest) />
		<cfset basePath = reverse(listRest(reverse(basePath),"/\")) />
		
		<!--- TODO: determine if there is a "www" folder, if so, copy to the webroot if the user said to --->
		<cfif bCopyFilesToWebroot>
			<cfdirectory action="list" recurse="false" directory="#basePath#" filter="www" name="qWwwDir" />
			<cfif qWwwDir.recordCount>
				
				<!--- TODO: we need to load the config info to get the www folder info 
					(projectRoot + /www for advanced, project root for standalone, specified project dir for subdir) --->
				
				<!--- TODO: copy www files to wwwFolder + [pluginname]] --->
				
			</cfif>
		</cfif>
		
		<!--- TODO: copy plugin files to the plugins/[pluginname] folder --->
		<cfdirectory action="list" directory="#basePath#" recurse="true" name="qPluginFiles" sort="directory asc, name asc" />
		<cfset destinationPath = request.projectConfig.paths.plugins & "/" & pluginName />
		<cfif not directoryExists(destinationPath)>
			<cfset directoryCreate(destinationPath) />
		</cfif>

		<!--- TODO: modify the farCryConstructor.cfm to add the plugin --->
		
	</cfif>
	
</cfif>

<!--- TODO: determine if this is a subdirectory install.  if so, we should ask which project they want to install this for --->

<cfparam name="status" default="" />
<cfparam name="message" default="" />

<cfheader name="Content-Type" value="text/xml" />
<cfoutput> 
<response <cfif len(status)>status="#status#"</cfif> showresponse="true"> 
	<ide <cfif len(message)>message="#message#"</cfif> handlerfile="installPlugin.cfm"> 
		<dialog width="600" height="400" title="Install Plugin"> 
			<input name="pluginName" label="Plugin folder name" type="string" required="true" errormesssage="You must provide a plugin name" helpmessage="The name of the plugin.  This will be used as the folder name (ex. farcrycms)" />
			<input name="pathToPluginSource" label="Plugin Source (zip or manifest.cfc):" required="true" type="file" pattern="^.+((\.zip)|(manifest\.cfc))" errormessage="Must be a zip or manifest.cfc file!" />
			<!--- TODO: add field to indicate that existing files should be deleted --->
			<input name="bCopyFilesToWebroot" label="Copy www files to webroot?" required="true" errormessage="Please indicate if you would like to copy the www files to the webroot" type="list" helpmessage="Selecting yes will copy the www files to the project webroot.  If you select no, you may need to create a webserver alias to the plugin's www folder.">
				<option value="Yes" />
				<option value="No" />
			</input> 
		</dialog> 
	</ide> 
</response> 
</cfoutput>

<cfsetting enablecfoutputonly="false" />