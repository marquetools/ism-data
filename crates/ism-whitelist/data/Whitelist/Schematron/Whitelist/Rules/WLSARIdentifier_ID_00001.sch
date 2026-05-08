<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLSARIdentifier-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLSARIdentifier-ID-00001][Error] Whitelist Validation - each @ism:SARIdentifier attribute value in document must exist in the whitelist.
    
    Human Readable: Whitelist Validation Error - each @ism:SARIdentifier attribute value in document must exist in the whitelist.                    
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:SARIdentifier attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"
    value="*[@ism:SARIdentifier]"/>
  <sch:param name="searchTermList" value="@ism:SARIdentifier"/>
  <sch:param name="list" value="$SARIdentifierList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLSARIdentifier-ID-00001]  Whitelist Validation - each @ism:SARIdentifier attribute value in document must exist in the whitelist.'"/>
  
</sch:pattern>