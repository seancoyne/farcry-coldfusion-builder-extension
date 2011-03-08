<cfsetting enablecfoutputonly="true" showdebugoutput="false" />
<cfimport taglib="tags/webskin" prefix="skin" />

<cfset ideXml = xmlParse(form.ideEventInfo) />
<cfset bPluginInstalled = false />

<!--- ensure project has been configured --->
<cfif not structKeyExists(request,"projectConfig")>
	<skin:contentWrapperMain workbench="dialog" title="Project Needs Configuration!" width="600" height="400">
		<cfoutput>
			<h1>Sorry, you must configure this project before you can install a plugin.</h1>
		</cfoutput>
	</skin:contentWrapperMain>
<cfelse>
	
	<cfif structKeyExists(ideXml["event"]["user"],"input")>
		
		<cfset pluginName = application.oCustomFunctions.getInputValue(ideXml,'pluginName') />
		<cfset pathToPluginSource = application.oCustomFunctions.getInputValue(ideXml,'pathToPluginSource') />
		<cfset bCopyFilesToWebroot = application.oCustomFunctions.getInputValue(ideXml,'bCopyFilesToWebroot',false) />
		<cfset bRemoveExistingFiles = application.oCustomFunctions.getInputValue(ideXml,'bRemoveExistingFiles',false) />
		<cfset selectedProject = application.oCustomFunctions.getInputValue(ideXml,'selectedProject') />
		
		<!--- validate the form data --->
		<cfset bHasError = false />
		
		<cfif not len(trim(pluginName))>
			<cfset bHasError = true />
			<cfset status = "error" />
			<cfset message = "You must provide a plugin name" />
		</cfif>
		
		<cfif not len(trim(pathToPluginSource))>
			<cfset bHasError = true />
			<cfset status = "error" />
			<cfset message = "You must provide the plugin source" />
		</cfif>
		
		<cfif request.projectConfig.installationType eq "subdirectory">
			<cfif not len(trim(selectedProject))>
				<cfset bHasError = true />
				<cfset status = "error" />
				<cfset message = "You must choose the subdirectory FarCry project you wish to use" />
			</cfif>
		</cfif>
		
		<cfif not bHasError>
		
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
				
				<!--- get the "www" path for this FarCry project --->
				<cfswitch expression="#request.projectConfig.installationType#">
					<cfcase value="standalone">
						<!--- for standalone, the eclipse project root is the www folder --->
						<cfset wwwLocation = ideXml["event"]["ide"]["projectview"].xmlAttributes["projectlocation"] />
					</cfcase>
					<cfcase value="subdirectory">
						<!--- for a subdirectory install, the www folder is the subdirectory --->
						<cfset wwwLocation = ideXml["event"]["ide"]["projectview"].xmlAttributes["projectlocation"] & "/" & selectedProject />
					</cfcase>
					<cfcase value="advanced">
						<!--- for an advanced install, the www folder is the www folder inside the eclipse project --->
						<cfset wwwLocation = ideXml["event"]["ide"]["projectview"].xmlAttributes["projectlocation"] & "/www" />
					</cfcase>
					<cfdefaultcase>
						<cfset wwwLocation = "" />
					</cfdefaultcase>
				</cfswitch>
				
				<!--- determine if there is a "www" folder in the plugin, if so, copy to the webroot if the user said to --->
				<cfif len(wwwLocation) and bCopyFilesToWebroot>
				
					<cfdirectory action="list" recurse="false" directory="#basePath#" filter="www" name="qWwwDir" />
					
					<cfif qWwwDir.recordCount>
		
						<cfif not directoryExists(wwwLocation & "/" & pluginName)>
							<!--- target directory doesn't exist, create it --->
							<cfset directoryCreate(wwwLocation & "/" & pluginName) />
						<cfelseif bRemoveExistingFiles eq true>
							<!--- target directory exists, but we want to remove any existing files, so delete it, then recreate --->
							<cfset directoryDelete(wwwLocation & "/" & pluginName,true) />
							<cfset directoryCreate(wwwLocation & "/" & pluginName) />
						</cfif>
						
						<!--- copy www files to wwwFolder + [pluginname]] --->
						<cfset sourceDir = basePath & "/www" />
						<cfset targetDir = wwwLocation & "/" & pluginName />
						<cfdirectory action="list" recurse="true" directory="#sourceDir#" name="qWWWFiles" sort="directory asc, name asc" type="file" />
						<cfloop query="qWWWFiles">
							<cfset subdir = replace(directory,sourceDir,"") />
							<cfif len(subdir)>
								<cfif not directoryExists(targetDir & "/" & subdir)>
									<cfset directoryCreate(targetDir & "/" & subdir) />
								</cfif>
								<cffile action="copy" source="#directory#/#name#" destination="#targetDir#/#subdir#/#name#" />
							<cfelse>
								<cffile action="copy" source="#directory#/#name#" destination="#targetDir#/#name#" />
							</cfif>
						</cfloop>
						
					</cfif>
					
				</cfif>
				
				<!--- copy plugin files to the plugins/[pluginname] folder --->
				<cfif not directoryExists(request.projectConfig.path.plugins & "/" & pluginName)>
					<cfset directoryCreate(request.projectConfig.path.plugins & "/" & pluginName) />
				<cfelseif bRemoveExistingFiles>
					<!--- remove existing plugin files --->
					<cfset directoryDelete(request.projectConfig.path.plugins & "/" & pluginName, true) />
					<cfset directoryCreate(request.projectConfig.path.plugins & "/" & pluginName) />
				</cfif>
				<cfset targetDir = request.projectConfig.path.plugins & "/" & pluginName />
				<cfdirectory action="list" recurse="true" directory="#basePath#" name="qPluginFiles" sort="directory asc, name asc" type="file" />
				<cfloop query="qPluginFiles">
					<cfset subdir = replace(directory,basePath,"") />
					<cfif len(subdir)>
						<cfif not directoryExists(targetDir & "/" & subdir)>
							<cfset directoryCreate(targetDir & "/" & subdir) />
						</cfif>
						<cffile action="copy" source="#directory#/#name#" destination="#targetDir#/#subdir#/#name#" />
					<cfelse>
						<cffile action="copy" source="#directory#/#name#" destination="#targetDir#/#name#" />
					</cfif>
				</cfloop>
				
				<!--- update the farcry constructor to add the plugin to the list of plugins --->
				<cfif len(wwwLocation) and fileExists(wwwLocation & "/farcryConstructor.cfm")>
					<cfset farCryConstructorContent = application.oCustomFunctions.addPluginToList(fileRead(wwwLocation & "/farcryConstructor.cfm"), pluginName) />
					<cfset fileWrite(wwwLocation & "/farcryConstructor.cfm",farCryConstructorContent,"utf-8") />
				</cfif>
				
				<cfset bPluginInstalled = true />
				
			</cfif>
			
		</cfif>
		
	</cfif>
	 
	<cfif bPluginInstalled eq true>
		
		<skin:contentWrapperMain workbench="dialog" title="Installation Successful!" width="600" height="400">
			
			<cfoutput>
				
				<h1>Plugin installation successful!</h1>
				
				<p>You will need to reinitialize the application (ex http://servername/?updateapp=1) and deploy any content types
				or rules for the new plugin from the FarCry webtop.</p>
				
				<p>
					Plugin installed at:<br />
					<textarea style="width: 400px; height: 40px;">#request.projectConfig.path.plugins & "/" & pluginName#</textarea>	
				</p>
				
				<cfif bCopyFilesToWebroot>
					<p>
						Plugin "www" files installed at:<br />
						<textarea style="width: 400px; height: 40px;">#wwwLocation#/#pluginName#</textarea>
					</p>
				<cfelse>
					<p>If the plugin contains a "www" folder you will need to create a web server alias called "#pluginName#" pointing to this folder.</p>
				</cfif>
				
				<cfif bRemoveExistingFiles>
					<p>Existing files were removed prior to plugin installation.</p>
				</cfif>
				
			</cfoutput>
			
		</skin:contentWrapperMain>
				
	<cfelse>
		<cfparam name="status" default="" />
		<cfparam name="message" default="" />
		<cfheader name="Content-Type" value="text/xml" />
		<cfoutput> 
		<response <cfif len(trim(status))>status="#xmlFormat(status)#"</cfif> showresponse="true"> 
			<ide <cfif len(trim(message))>message="#xmlFormat(message)#"</cfif> handlerfile="installPlugin.cfm">	
				<dialog width="600" height="400" title="Install Plugin"> 
					<cfif request.projectConfig.installationType eq "subdirectory">
						<cfdirectory action="list" name="qSubDirFolders" directory="#request.projectConfig.path.projects#" type="dir" recurse="false" sort="name asc" />
						<cfquery name="qSubDirFolders" dbtype="query">
						select * from qSubDirFolders where name not like '.%'
						</cfquery>
						<cfif qSubDirFolders.recordCount>
							<input name="selectedProject" label="Project" type="list" required="true" errormessage="Please choose which subdirectory project you would like to use" helpmessage="The subdirectory project you would like to use">
								<cfloop query="qSubDirFolders">
									<option value="#name#" />
								</cfloop>
							</input>
						</cfif>
					</cfif>
					<input name="pluginName" label="Plugin folder name" type="string" required="true" errormessage="You must provide a plugin folder name" helpmessage="This will be used as the folder name (ex. farcrycms)" />
					<input name="pathToPluginSource" label="Plugin Source (zip or manifest.cfc):" required="true" type="file" pattern="^.+((\.zip)|(manifest\.cfc))" errormessage="Must be a zip or manifest.cfc file!" />
					<input name="bCopyFilesToWebroot" label="Copy www files to webroot?" type="list" required="true" errormessage="Please indicate if you would like to copy the www files to the webroot" helpmessage="Selecting yes will copy the www files to the project webroot.  If you select no, you may need to create a webserver alias to the plugin's www folder (if it has one).">
						<option value="Yes" />
						<option value="No" />
					</input> 
					<input name="bRemoveExistingFiles" label="Remove existing files?" type="list" required="true" errormessage="Please indicate if you would like existing files removed" helpmessage="If you select yes, any existing files in the target directories will be removed.  Choose no to keep existing files.">
						<option value="Yes" />
						<option value="No" />
					</input>
				</dialog> 
			</ide> 
		</response> 
		</cfoutput>
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false" />