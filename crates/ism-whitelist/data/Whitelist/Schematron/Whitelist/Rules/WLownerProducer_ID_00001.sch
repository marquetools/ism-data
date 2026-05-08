<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLownerProducer-ID-00001"
  is-a="ValidateTokensExistInWhitelist">
  <sch:p class="ruleText">
    [WLownerProducer-ID-00001][Error]  Whitelist Validation - each @ism:ownerProducer value in document must exist in whitelist.
  </sch:p>
  <sch:p class="codeDesc">
    If OwnerProducer/values@type = 'whitelist', 
    then all ism:ownerProducer values must exist in OwnerProducer/values.
    Leaving the values element empty with @type = 'whitelist' means that any value will fail.
    
  </sch:p>
  
  <sch:param name="context"    value="*[($ownerProducerListType = 'whitelist') and @ism:ownerProducer]"/>
  <sch:param name="searchTermList" value="@ism:ownerProducer"/>
  <sch:param name="list" value="$ownerProducerList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLownerProducer-ID-00001][Error] Whitelist Validation - each @ism:ownerProducer value in document must exist in whitelist.'"/>
  
</sch:pattern>