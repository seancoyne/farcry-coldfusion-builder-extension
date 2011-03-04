<cfcomponent output="false"><!--- extends="cfc.update.BaseApplication" --->
	<cfset this.name = "FarCryCFBuilderExtension" />
	
	<!--- TODO: turn the updater back on --->
	
	<cffunction name="onApplicationStart" output="false" returntype="boolean">
		<cfset application.oCustomFunctions = createObject("component","cfc.common.customFunctions") />
		<!---<cfreturn super.onApplicationStart() />--->
		<cfreturn true />
	</cffunction>
	
	<cffunction name="onRequestStart" output="false" returntype="boolean">
		<cfargument name="thePage" type="string" required="true" />
		
		<!--- TODO: remove this --->
		<cfset application.oCustomFunctions = createObject("component","cfc.common.customFunctions") />
		
		<cfif structKeyExists(url,"reload")>
			<cflock scope="Application" timeout="5">
				<cfset onApplicationStart() />
			</cflock>
		</cfif>
		
		<!---<cfreturn super.onRequestStart(argumentCollection = arguments) />--->
		<cfreturn true />
		
	</cffunction>
	
</cfcomponent>