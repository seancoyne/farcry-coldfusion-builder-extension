<cfsetting enablecfoutputonly="true" />

<cfif thisTag.executionmode neq "start"><cfsetting enablecfoutputonly="false" /><cfexit method="exitTag" /></cfif>

<cfoutput>
    </div>
  </div>
  <div id="footer"><p id="copyright">copyright &copy;2011<cfif year(now()) gt 2011>, #year(now())#</cfif> <a href="http://jeffcoughlin.com/blog">Jeff Coughlin</a>, <a href="http://n42designs.com">Sean Coyne</a>. All rights reserved.</p></div>
</div><!-- /##content -->
</body>
</html></cfoutput>

<cfsetting enablecfoutputonly="false" />