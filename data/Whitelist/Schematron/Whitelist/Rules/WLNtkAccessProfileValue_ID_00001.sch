<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
  id="WLNtkAccessProfileValue-ID-00001">
  
  <sch:p class="ruleText">
    [WLNtkAccessProfileValue-ID-00001][Error] RequiresAnyOf NTK Whitelist Validation - For each profile within an NTK RequiresAnyOf element, 
    at least one AccessProfileValue must be specified in the whitelist.  For urn:us:gov:ic:aces:ntk:restrictive profiles, every AccessProfileValue 
    for that profile must be defined in the whitelist. For urn:us:gov:ic:aces:ntk:permissive profiles, at least one AccessProfileValue must be defined.
    
    Human Readable: Whitelist RequiresAnyOf Validation Error: for RequiresAnyOf profiles, at least one combination of AccessPolicy, AccessProfileValue@ntk:vocabulary 
    and ntk:AccessProfileValue from document must be specified for the profile in the whitelist.
  </sch:p>
  
  <sch:p class="codeDesc">
    Utilizes the AnyAccessProfileInWhitelist abstract rule.  The abstract rule handles the variations in behavior with the restrictive / permissive profiles,
    the propin:1 profile with no AccessProfileValues and the ICO profile.  
  </sch:p>
   
  <sch:rule id="WLNtkAccessProfileValue-ID-00001-R1" context="//ntk:RequiresAnyOf/ntk:AccessProfileList">
     <sch:assert 
        test="some $docProfile in ./ntk:AccessProfile satisfies (
                 
                   (  $docProfile/ntk:AccessPolicy = 'urn:us:gov:ic:aces:ntk:ico' )
                   or
                   (  $docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1' 
                      and
                      not($docProfile[$docProfile/ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:propin:1']/ntk:AccessProfileValue)
                   )
                   or
                   (  if ($docProfile/ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive') 
                      then every $docTerm in for $value in $docProfile[./ntk:AccessPolicy != 'urn:us:gov:ic:aces:ntk:permissive']/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))
                           satisfies some $listTerm in $accessProfileValueList satisfies (matches ($docTerm, $listTerm))  
                      else some $docTerm in for $value in $docProfile[./ntk:AccessPolicy='urn:us:gov:ic:aces:ntk:permissive']/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',  $value/@ntk:vocabulary, ' ', $value))  
                           satisfies some $listTerm in $accessProfileValueListPermissive satisfies (matches ($docTerm, $listTerm))
                   )
                  
        )" flag="error" role="error">

      [WLNtkAccessProfileValue-ID-00001][Error] RequiresAnyOf NTK Whitelist Validation - For each profile within an NTK RequiresAnyOf element, 
      at least one AccessProfileValue must be specified in the whitelist.  For urn:us:gov:ic:aces:ntk:restrictive profiles, every AccessProfileValue 
      must be defined in the whitelist. For urn:us:gov:ic:aces:ntk:permissive profiles, at least one AccessProfileValue must be defined.
      
      Document Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence(for $value in ./ntk:AccessProfile/ntk:AccessProfileValue return normalize-space(concat($value/../ntk:AccessPolicy, ' ',$value/@ntk:vocabulary, ' ', $value)))"/>]
      
      Whitelist Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileValueList)"/>
                           <sch:value-of select="util:getCommaSeparatedStringFromSequence($accessProfileValueListPermissive)"/>]     
    </sch:assert>
  </sch:rule>  
</sch:pattern>
