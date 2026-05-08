<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLSCIcontrols-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLSCIcontrols-ID-00001][Error] Whitelist Validation - each @ism:SCIcontrols each combination must be specified in the whitelist.
    
    Human Readable: SCIcontrols Validation Error:  each @ism:SCIcontrols value in document must exist in whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:SCIcontrols attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:SCIcontrols]"/>
  <sch:param name="searchTermList" value="@ism:SCIcontrols"/>
  <sch:param name="list" value="$SCIControlsList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLSCIcontrols-ID-00001][Error] Whitelist Validation - each @ism:SCIcontrols each combination must be specified in the whitelist.'"/>
  
</sch:pattern>