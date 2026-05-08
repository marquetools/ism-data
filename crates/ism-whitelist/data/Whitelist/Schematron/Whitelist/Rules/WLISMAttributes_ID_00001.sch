<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLISMAttribute-ID-00001"
  is-a="ValidateTokensExistInWhitelist">
  <sch:p class="ruleText">
    [WLISMAttributes-ID-00001][Error]  Whitelist Validation - each @ism attribute in document must exist in whitelist.
  </sch:p>
  <sch:p class="codeDesc">
    If ISMAttributes/values@type = 'whitelist', 
    then all ism: attribute values must exist in ISMAttributes/values.
    Leaving the values element empty with @type = 'whitelist' means that any ism attribute will fail.    
  </sch:p>
  
  <sch:param name="context"    value="*[//@*[namespace-uri()='urn:us:gov:ic:ism']]"/>
  <sch:param name="searchTermList" value="util:getSpaceSeparatedStringFromSequence(@*[namespace-uri()='urn:us:gov:ic:ism']/local-name())"/>
  <sch:param name="list" value="$ismAttributesList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLISMAttribute-ID-00001][Error] Whitelist Validation - each @ism: attribute in document must exist in whitelist.'"/>
  
</sch:pattern>