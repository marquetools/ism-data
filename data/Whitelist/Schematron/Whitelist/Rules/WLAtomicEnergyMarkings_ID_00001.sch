<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLAtomicEnergyMarkings-ID-00001" 
  is-a="ValidateTokensExistInWhitelist">
  
  <sch:p class="ruleText">
    [WLAtomicEnergyMarkings-ID-00001][Error] Whitelist Validation - @ism:atomicEnergyMarkings combination must be specified in the whitelist.
    
    Human Readable: Whitelist Validation Error - ism:atomicEnergyMarkings value must be specified in the whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    ism:atomicEnergyMarkings attributes in document must be specified in whitelist.
    If no values defined in whitelist, then element is not allowed.
  </sch:p>
  
  <sch:param name="context"    value="*[@ism:atomicEnergyMarkings]"/>
  <sch:param name="searchTermList" value="@ism:atomicEnergyMarkings"/>
  <sch:param name="list" value="$atomicEnergyMarkingsList_tok"/>
  <sch:param name="errMsg"
    value="'   [WLAtomicEnergyMarkings-ID-00001][Error]  Whitelist Validation - @ism:atomicEnergyMarkings combination must be specified in the whitelist.'"/>
  
</sch:pattern>