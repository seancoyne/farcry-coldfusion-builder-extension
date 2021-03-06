<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

  <cfset configData = {} />
  
  <cfparam name="form.pathToFarCry" default="" type="string" />
  <cfparam name="form.farCryVersion" default="" type="string" />
  <cfparam name="form.installationType" default="" type="string" />
  <cfparam name="form.eclipseProjectName" default="" type="string" />
  <cfparam name="form.farCryProjectDirectoryName" default="" type="string" />
  
<cfscript>
  // trim form fields
  for (field in form) {
    form[field] = trim(form[field]);
  }

  // Form validation
  variables.stErrors = {};
  
  if (form.installationType eq ''){
    variables.stErrors.installationType = "Installation type required.";
  }
  if (form.farCryProjectDirectoryName eq '' and listFindNoCase("advanced,standalone", form.installationType) gt 0){
    variables.stErrors.farCryProjectDirectoryName = "FarCry project directory name is required.";
  }
  if (form.pathToFarCry eq ''){
    variables.stErrors.pathToFarCry = "Path to FarCry folder is required.";
  }
  if (form.farCryVersionShort eq ''){
    variables.stErrors.farCryVersionShort = "FarCry version is required.";
  }
  if (form.eclipseProjectName eq ''){
    variables.stErrors.eclipseProjectName = "Unknown Eclipse project name: Sorry, but we cannot detect your Eclipse project name and thus can't continue.";
  }
</cfscript>
  
<cfif structCount(variables.stErrors) eq 0>
  <cfset configData["path"] = {} />
  <cfset configData["path"]["FarCry"] = form.pathToFarCry />
  <cfset configData["path"]["Core"] = form.pathToFarCry & "/core" />
  <cfset configData["path"]["Plugins"] = form.pathToFarCry & "/plugins" />
  <cfset configData["path"]["Projects"] = form.pathToFarCry & "/projects" />
  <cfset configData["farCryVersion"] = form.farCryVersionFull />
  <cfset configData["installationType"] = form.installationType />
  <cfif form.installationType eq "subdirectory">
    <cfset configData["farCryProjectDirectoryName"] = "" />
  <cfelse>
    <cfset configData["farCryProjectDirectoryName"] = form.farCryProjectDirectoryName />
  </cfif>
  <cfset dateTimelastUpdated = "#createODBCDatetime(now())#" />
  <cfif structKeyExists(request,"projectConfig") is false>
    <cfset dateTimeCreated = "#createODBCDatetime(now())#" />
  </cfif>
  
  <!--- save the configuration data --->
  <cfset jsonData = serializeJson(configData) />
  <cfset configPath = expandPath('../config/projects') />
  
  <cftry>
  <!--- clean up the project name so it is safe to save as a file name --->
  <cfset fileName = application.oCustomFunctions.cleanFileName(form.eclipseProjectName) />
  <cffile action="write" file="#configPath#/#fileName#.json" output="#trim(jsonData)#" addnewline="false" mode="775" />
    <cfcatch>
      <cfset variables.stErrors.message = "Configuration file write error. The extension cannot work without the ability to write to the config file. Please check that ColdFusion has write access to the extension folders." />
    </cfcatch>    
  </cftry>
</cfif>

<cfif structCount(variables.stErrors) gt 0>
  <cfset variables.command = "formPage" />
<cfelse>
  <cfset variables.command = "completePage" />
</cfif>

<cfsetting enablecfoutputonly="false" />