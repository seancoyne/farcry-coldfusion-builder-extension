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
  if (form.farCryProjectDirectoryName eq '' and form.installationType eq 'advanced'){
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
  
  <cfset configData["path"] = {} />
  <cfset configData["path"]["FarCry"] = form.pathToFarCry />
  <cfset configData["path"]["Core"] = form.pathToFarCry & "/core" />
  <cfset configData["path"]["Plugins"] = form.pathToFarCry & "/plugins" />
  <cfset configData["path"]["Projects"] = form.pathToFarCry & "/projects" />
  <cfset configData["farCryVersionShort"] = form.farCryVersionShort />
  <cfset configData["farCryVersionFull"] = form.farCryVersionFull />
  <cfset configData["installationType"] = form.installationType />
  <cfif listFindNoCase("subdirectory,standalone", form.installationType) neq "">
    <cfset configData["farCryProjectDirectoryName"] = "" />
  <cfelse>
    <cfset configData["farCryProjectDirectoryName"] = form.farCryProjectDirectoryName />
  </cfif>
  
  <!--- save the configuration data --->
  <cfset jsonData = serializeJson(configData) />
  <cfset configPath = expandPath('../config/projects') />
  
  <cftry>
  <!--- clean up the project name so it is safe to save as a file name --->
  <cfset fileName = application.oCustomFunctions.cleanFileName(form.eclipseProjectName) />
  <cffile action="write" file="#configPath#/#fileName#.json" output="#trim(jsonData)#" addnewline="false" />
    <cfcatch>
      <cfset variables.stErrors.message = "Configuration file write error. The extension cannot work without the ability to write to the config file. Please check that Coldfusion has write access to the extension folders." />
    </cfcatch>    
  </cftry>
  
<cfif structCount(variables.stErrors) gt 0>
  <cfset variables.command = "formPage" />
<cfelse>
  <cfset variables.command = "completePage" />
</cfif>

<cfsetting enablecfoutputonly="false" />