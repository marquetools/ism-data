<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLdisplayOnlyTo-ID-00001"
  is-a="ValidateDecomposableTokensExistInWhitelist">
  <sch:p class="ruleText">
    [WLdisplayOnlyTo-ID-00001][Error]  Whitelist Validation - each @ism:displayOnlyTo value in document must exist in whitelist.
  </sch:p>
  <sch:p class="codeDesc">
    If DisplayOnlyTo/values@type = 'whitelist',
    then all ism:displayOnlyTo values must exist in DisplayOnlyTo/values.  Tetragraphs will be decomposed.
    Leaving the values element empty with @type = 'whitelist' means that any value will fail.    
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:displayOnlyTo]"/>
  <sch:param name="searchTermList" value="@ism:displayOnlyTo"/>
  <sch:param name="list" value="$displayOnlyToList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLdisplayOnlyTo-ID-00001][Error] Whitelist Validation - each @ism:displayOnlyTo value in document must exist in whitelist.'"/>
  
</sch:pattern>