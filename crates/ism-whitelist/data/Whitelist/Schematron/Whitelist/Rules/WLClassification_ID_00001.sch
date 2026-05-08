<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLClassification-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLClassification-ID-00001][Error] Whitelist Validation - @ism:classification value in document must exist in the whitelist.
    
    Human Readable: Whitelist Validation Error - ism:classification attributes in document must be specified in whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:Classification attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"
             value="*[@ism:classification]"/>
  <sch:param name="searchTermList" value="@ism:classification"/>
  <sch:param name="list" value="$classificationList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLClassification-ID-00001][Error] Whitelist Validation - @ism:classification value in document must exist in the whitelist.'"/>
  
</sch:pattern>