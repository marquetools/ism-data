<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLnonICmarkings-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLnonICmarkings-ID-00001][Error] Whitelist validation: each @ism:nonICmarkings value in document must exist in whitelist.
    
    Human Readable:   Whitelist Validation Error: each @ism:nonICmarkings value in document must exist in whitelist.                       
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:SCIcontrols attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:nonICmarkings]"/>
  <sch:param name="searchTermList" value="@ism:nonICmarkings"/>
  <sch:param name="list" value="$nonICmarkingsList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLnonICmarkings-ID-00001][Error] Whitelist validation: each @ism:nonICmarkings value in document must exist in whitelist.'"/>
  
</sch:pattern>