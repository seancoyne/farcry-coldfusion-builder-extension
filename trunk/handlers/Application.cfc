<cfcomponent extends="cfc.update.BaseApplication">
	<cfset this.name = "FarCryCFBuilderExtension" />
	
	<cffunction name="onApplicationStart" output="false" returntype="boolean">
		<cfset application.oCustomFunctions = createObject("component","cfc.common.customFunctions") />
		<cfreturn super.onApplicationStart() />
	</cffunction>
	
	<cffunction name="onRequestStart" output="false" returntype="boolean">
		<cfargument name="targetPage" type="string" required="true" />
		
		<cfsetting showdebugoutput="false" />
		
		<!--- TODO: remove this (it is set in the application.cfc) --->
		<cfset application.oCustomFunctions = createObject("component","cfc.common.customFunctions") />
		
		<cfif structKeyExists(url,"reload")>
			<cflock scope="Application" timeout="5">
				<cfset onApplicationStart() />
			</cflock>
		</cfif>
		
		<!--- fix to prevent ajax requests from being broken by onRequest (required for the updater) --->
		<cfif listLast(arguments.targetPage,".") eq "cfc">
			<cfset structDelete(this,"onRequest") />
			<cfset structDelete(variables,"onRequest") />
		</cfif>
		
		<!--- load project configuration info --->
		<cfif structKeyExists(form,"ideEventInfo")>
			<cfif isXml(form.ideEventInfo)>
				<cfset var ideInfo = xmlParse(form.ideEventInfo) />
				<cfset request.projectName = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectname"] />
				<cfset request.projectConfig = application.oCustomFunctions.loadProjectConfig(projectName = request.projectName, configPath = expandPath("../config/projects")) />
				<cfif not structCount(request.projectConfig)>
					<cfset structDelete(request,"projectConfig") />
				</cfif>
			</cfif>
		</cfif>
		
		<!--- load extension config --->
		<cfset request.extensionConfig = application.oCustomFunctions.loadExtensionConfig() />
		
		<cfreturn true />
		
	</cffunction>
	
	<cffunction name="onRequest" output="true" returntype="void">
		<cfargument name="targetPage" required="true" type="string" />
		<cfset super.onRequest(targetPage = arguments.targetPage) />
		<cfinclude template="#arguments.targetPage#" />
	</cffunction>
	
</cfcomponent>