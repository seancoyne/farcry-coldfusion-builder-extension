<cfsetting enablecfoutputonly="true" />

<cfif thisTag.executionmode neq "start"><cfsetting enablecfoutputonly="false" /><cfexit method="exitTag" /></cfif>

<cfparam name="attributes.pageTitle" default="" />

<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <title><cfif attributes.pageTitle neq "">#attributes.pageTitle# // </cfif>FarCry Framework Utilities</title>
  <link rel="stylesheet" type="text/css" media="screen" href="#application.oCustomFunctions.getCurrentDir()#/css/screen.css" />
  <link rel="stylesheet" type="text/css" media="screen" href="#application.oCustomFunctions.getCurrentDir()#/css/jquery-ui-redmond/jquery-ui-1.8.10.custom.css" />
  <script type="text/javascript" src="#application.oCustomFunctions.getCurrentDir()#/js/jquery-1.5.1.min.js" />
  <script type="text/javascript" src="#application.oCustomFunctions.getCurrentDir()#/js/jquery-ui-1.9.10.custom.min.js" />
</head>
<body>
  <div id="content">
</cfoutput>

<cfsetting enablecfoutputonly="false" />