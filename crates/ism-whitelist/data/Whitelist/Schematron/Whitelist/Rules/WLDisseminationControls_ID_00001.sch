<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLDisseminationControls-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLDisseminationControls-ID-00001][Error] Whitelist Validation - each @ism:disseminationControls value in document must exist in the whitelist.
    
    Human Readable: Whitelist Validation Error - each @ism:disseminationControls value in document must exist in the whitelist.
                    
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:disseminationControls attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:disseminationControls]"/>
  <sch:param name="searchTermList" value="@ism:disseminationControls"/>
  <sch:param name="list" value="$disseminationControlsList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLDisseminationControls-ID-00001][Error] Whitelist Validation - each @ism:disseminationControls value in document must exist in the whitelist.'"/>
  
</sch:pattern>