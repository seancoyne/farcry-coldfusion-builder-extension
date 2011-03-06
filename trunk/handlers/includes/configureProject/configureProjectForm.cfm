<cfsetting enablecfoutputonly="true" showdebugoutput="false" />

<!--- NOTE: We assume structKeyExists for form.ideEventInfo --->

  <!--- TODO: check for json file first --->
  
  <cfparam name="variables.stErrors" default="#{}#" />
  <cfset checkFormError = application.oCustomFunctions.checkFormError />
  <cfset bDisplayNotifications = false />

  <cfset ideInfo = xmlParse(form.ideEventInfo) />
    
  <cfset projectName = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectname"] />
  <cfset projectLocation = ideInfo["event"]["ide"]["projectview"].xmlAttributes["projectLocation"] />

  <cfif structKeyExists(form, "installationType")>
    <!--- The form was submitted, but likely failed validation. So pre-fill previous answers --->

    <cfset configData = { 
      pathToFarCry = form["pathToFarCry"], 
      installationType = form["installationType"], 
      farCryVersionShort = form["farCryVersionShort"], 
      farCryVersionFull = form["farCryVersionFull"], 
      farCryProjectDirectoryName = form["farCryProjectDirectoryName"]
    } />

  <cfelseif structKeyExists(request,"projectConfig")>
    
    <cfset configData = request.projectConfig />
    
    <cfset configData.pathToFarCry = configData.path.farcry />
    <cfset configData.farCryVersionShort = configData.farCryVersionShort />
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

  <cfoutput>
    
    <script type="text/javascript">
      $(document).ready(function(){
        
      });
    </script>
        
    <h1>FarCry Project Config Settings</h1>

    <p>The plugin needs to know your FarCry configuration settings for this Eclipse project.  This gives you the flexibility of having a different FarCry configuration per Eclipse project.</p>

    <!---  Notifications here
    Suggestions: 1. First time creating for this Eclipse project
                 2. New fields since last update
                 3. Form errors
                 4. jQuery messages
    --->
    <cfif structCount(variables.stErrors) gt 0>
      <cfset bDisplayNotifications = true />
    </cfif>
    <blockquote style="<cfif bDisplayNotifications is false>display: none;</cfif>">
      <cfif structCount(variables.stErrors) gt 0>
        <h2>Please review any error messages below</h2>
        <ol>
          <cfloop collection="#variables.stErrors#" item="errorMsg">
            <li>#variables.stErrors[errorMsg]#</li>
          </cfloop>
        </ol>
      </cfif>
    </blockquote>

    <form class="generic-form" action="#application.oCustomFunctions.getCurrentUrl()#" method="post">
      
      <fieldset id="farcry-info">
        <legend>FarCry Project Information</legend>
        <fieldset class="stacked-inputs">
          <ol>
            <li>
              <fieldset id="installation-type">
                <legend><span class="required">Installation Type</span></legend>
                <ul>
                  <li><label for="installationType_standalone"><input type="radio" name="installationType" id="installationType_standalone" value="standalone"<cfif configData.installationType eq "standalone"> checked="checked"</cfif> /> Standalone</label></li>
                  <li><label for="installationType_subdirectory"><input type="radio" name="installationType" id="installationType_subdirectory" value="subdirectory"<cfif configData.installationType eq "subdirectory"> checked="checked"</cfif> /> Subdirectory</label></li>
                  <li><label for="installationType_advanced"><input type="radio" name="installationType" id="installationType_advanced" value="advanced"<cfif configData.installationType eq "advanced"> checked="checked"</cfif> /> Advanced</label>
                    #checkFormError("installationType")#
                  </li>
                </ul>
              </fieldset>
            </li>
          </ol>
        </fieldset>
        <fieldset id="projectname-info">
          <ol>
            <li><label for="farCryProjectDirectoryName" class="required">FarCry Project Directory Name</label> <input type="text" id="farCryProjectDirectoryName" name="farCryProjectDirectoryName" value="#configData.farCryProjectDirectoryName#" />#checkFormError("farCryProjectDirectoryName")#</li>
            <li><label for="pathToFarCry" class="required">Path to FarCry Folder</label> <input type="text" id="pathToFarCry" name="pathToFarCry" value="#configData.pathToFarCry#" />#checkFormError("pathToFarCry")#</li>
          </ol>
        </fieldset>
        <!---
        <fieldset id="textarea-info">
          <ol>
              <li>
              <label for="message" class="required">Message</label>
              <textarea cols="30" rows="6" name="message" id="message"></textarea>
            </li>
          </ol>
        </fieldset>
        --->
        <fieldset id="farcryversion-info">
          <ol>
            <li>
              <label for="farCryVersionShort" class="required">FarCry Version</label>
              <select name="farCryVersionShort" id="farCryVersionShort">
                <option value="6.0.x"<cfif configData.farCryVersionShort eq "6.0.x"> selected="selected"</cfif>>6.0.x</option>
                <option value="6.1.x"<cfif configData.farCryVersionShort eq "6.1.x"> selected="selected"</cfif>>6.1.x</option>
              </select>
              #checkFormError("farCryVersionShort")#
            </li>
          </ol>
        </fieldset>
      </fieldset>
      <p>
        <input type="hidden" name="ideEventInfo" value="#htmlEditFormat(form.ideEventInfo)#" />
        <input type="hidden" name="projectName" value="#projectName#" />
        <input type="hidden" name="farCryVersionFull" value="#configData.farCryVersionFull#" />
        <input type="hidden" name="cmd" value="actionPage" />
        <button type="submit" class="submit" id="submit-farcry-info">Submit</button>
      </p>
    </form> 

  </cfoutput>

<cfsetting enablecfoutputonly="false" />