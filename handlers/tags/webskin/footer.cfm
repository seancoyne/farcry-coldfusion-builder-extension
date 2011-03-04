<cfsetting enablecfoutputonly="true" />

<cfif thisTag.executionmode neq "start"><cfsetting enablecfoutputonly="false" /><cfexit method="exitTag" /></cfif>

<cfoutput>
  </div>
  <div id="footer">copyright &copy;#year(now())# <a href="http://jeffcoughlin.com/blog">Jeff Coughlin</a>, <a href="http://n42designs.com">Sean Coyne</a></div>
</div><!-- /##content -->
</body>
</html></cfoutput>

<cfsetting enablecfoutputonly="false" />