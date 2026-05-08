<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLFGIsourceOpen-ID-00001"
  is-a="ValidateTokensExistInWhitelist">
  <sch:p class="ruleText">
    [WLFGIsourceOpen-ID-00001][Error]  Whitelist Validation - each @ism:FGIsourceOpen values in document must exist in whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    If FGIsourceOpen/values@type = 'whitelist',
    then all ism:FGIsourceOpen values must exist in FGIsourceOpen/values.
    Leaving the values element empty with @type = 'whitelist' means that any value will fail.
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:FGIsourceOpen]"/>
  <sch:param name="searchTermList" value="@ism:FGIsourceOpen"/>
  <sch:param name="list" value="$FGIsourceOpenList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLFGIsourceOpen-ID-00001][Error] Whitelist Validation - each @ism:FGIsourceOpen values in document must exist in whitelist.'"/>
  
</sch:pattern>