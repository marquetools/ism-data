<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLownerProducer-ID-00002"
  is-a="ValidateTokenValuesNotInBlacklist">
  <sch:p class="ruleText">
    [WLownerProducer-ID-00002][Error]  Blacklist Validation - @ism:ownerProducer values in document must not exist in blacklist.
  </sch:p>
  
  <sch:p class="codeDesc">
    If OwnerProducer/values@type = 'blacklist',
    then none of the ism:ownerProducer values must exist in OwnerProducer/values
    Leaving the values element empty with @type = 'blacklist' means that any value will pass.
  </sch:p>
  
  <sch:param name="context"    value="*[($ownerProducerListType = 'blacklist') and @ism:ownerProducer]"/>
  <sch:param name="searchTermList" value="@ism:ownerProducer"/>
  <sch:param name="list" value="$ownerProducerList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLownerProducer-ID-00002][Error] Blacklist Validation - @sm:ownerProducer values in document must not exist in blacklist.'"/>
  
</sch:pattern>