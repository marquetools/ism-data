<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLnonUSControls-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLnonUSControls-ID-00001][Error] Whitelist Validation - each @ism:nonUSControls attribute value in document must exist in the whitelist.
    
    Human Readable: Whitelist Validation Error - each @ism:nonUSControls attribute value in document must exist in the whitelist.                    
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:nonUSControls attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"
    value="*[@ism:nonUSControls]"/>
  <sch:param name="searchTermList" value="@ism:nonUSControls"/>
  <sch:param name="list" value="$nonUSControlsList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLnonUSControls-ID-00001]  Whitelist Validation - each @ism:nonUSControls attribute value in document must exist in the whitelist.'"/>
  
</sch:pattern>