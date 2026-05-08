<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLReleaseableTo-ID-00001"
  is-a="ValidateDecomposableTokensExistInWhitelist">
  <sch:p class="ruleText">
    [WLReleaseableTo-ID-00001][Error]  Whitelist Validation - each @ism:releasableTo value in document must exist in whitelist.
  </sch:p>
  <sch:p class="codeDesc">
    If ReleaseableTo/values@type = 'whitelist', 
    then all ism:releasableTo values must exist in ReleaseableTo/values.  Tetragraphs will be decomposed.
      Leaving the values element empty with @type = 'whitelist' means that any value will fail.

  </sch:p>
   
  <sch:param name="context"    value="*[@ism:releasableTo]"/>
  <sch:param name="searchTermList" value="@ism:releasableTo"/>
  <sch:param name="list" value="$releasableToList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLReleaseableTo-ID-00001][Error] Whitelist Validation - each @ism:releasableTo value in document must exist in whitelist.'"/>
  
</sch:pattern>