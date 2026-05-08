<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLNtkAccessProfileValue-ID-00003">
  <sch:p class="ruleText">
    [WLNtkAccessProfileValue-ID-00003][Error]  NTK Minimum Values Validation - at a minimum, each whitelist profile value, 
    defined by combination of AccessProfileValue@ntk:vocabulary and ntk:AccessProfileValue, must be found in document.
    
    Human Readable: At a minimum, each whitelist profile value, defined by combination of AccessProfileValue@ntk:vocabulary 
    and ntk:AccessProfileValue, must be found in document. Additional profile values can exist.
  </sch:p>
  <sch:p class="codeDesc">
    Minimum set of NTK Profile values that must exist in document being evaluated. Minimum value entry is a combination of 
    required profile values as specified by a combination of AccessProfileValue@ntk:vocabulary and ntk:AccessProfileValue.
    A list of required values is created from the configuration xml file for the profile. 
    Each NTK profile value found in xml document must exist in this list along with any other profiles.
  </sch:p>
  
  <sch:rule id="WLNtkAccessProfileValue-ID-00003-R1"
    context="//ntk:AccessProfileList/ntk:AccessProfile[some $policyTerm in ./ntk:AccessPolicy satisfies some $configPolicyTerm in $profilesWithMinValues satisfies matches($policyTerm, $configPolicyTerm) ]">
     <sch:assert 
       test="(some $listTerm in $accessProfileMinValueList satisfies
                some $docTerm in for $value in .[(. != 'urn:us:gov:ic:aces:ntk:permissive')]/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value)) 
                satisfies (matches ($docTerm, $listTerm))
              )" flag="error" role="error"> 
        
        [WLNtkAccessProfileValue-ID-00003][Error] NTK Minimum Values Validation - at a minimum, each whitelist profile value, 
        defined by combination of AccessProfileValue@ntk:vocabulary and ntk:AccessProfileValue, must be found in document.
        
        Document NTK Profiles[<sch:value-of select="util:getCommaSeparatedStringFromSequence( ./ntk:AccessPolicy )"/>]
        Profiles with Minimum Values Defined: [<sch:value-of select="util:getCommaSeparatedStringFromSequence($profilesWithMinValues)"/>]
        Document Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence(for $value in ./ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value)))"/>]
        Minimum required value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileMinValueList)"/>] 
     </sch:assert>
  </sch:rule>
</sch:pattern>
