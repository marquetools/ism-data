<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLFGIsourceProtected-ID-00001"
  is-a="ValidateTokensExistInWhitelist">
  <sch:p class="ruleText">
    [WLFGIsourceProtected-ID-00001][Error]  Whitelist Validation - each @ism:FGIsourceProtected value in document must exist in whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    If FGIsourceProtected/values@type = 'whitelist',
    then all ism:FGIsourceProtected values must exist in FGIsourceProtected/values.
    Leaving the values element empty with @type = 'whitelist' means that any value will fail.   
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:FGIsourceProtected]"/>
  <sch:param name="searchTermList" value="@ism:FGIsourceProtected"/>
  <sch:param name="list" value="$FGIsourceProtectedList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLFGIsourceProtected-ID-00001][Error] Whitelist Validation - each @ism:FGIsourceProtected value in document must exist in whitelist.'"/>
  
</sch:pattern>