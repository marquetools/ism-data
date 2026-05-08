<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
      id="WLReleaseableTo-ID-00002">
  <sch:p class="ruleText">
    [WLReleaseableTo-ID-00002][Error]  Whitelist Validation - if minimumValues is defined for a minimum set of relTo values, then 
                                       ensure that @ism:releasableTo values include each member of minimum values.
  </sch:p>
  <sch:p class="codeDesc">
    If config file ReleaseableTo element includes the minimumValues child,
    then each instance of ism:releaseableTo in the document must include each member listed
    in minimumValues.
  </sch:p>
   
  <sch:rule id="WLReleaseableTo-ID-00002-R1" context="*[@ism:releasableTo]">
    <sch:let name="searchTermList" value="@ism:releasableTo"/>
    <sch:assert test="every $Term in for $term in $releasableToMinList_tok return util:expandDecomposableTetras($term) satisfies
                        some $searchTerm in for $term in $searchTermList return util:expandDecomposableTetras($term) satisfies 
                           (matches (normalize-space($Term), concat('^', $searchTerm, '$')))"
                flag="error" role="error">
      [WLReleaseableTo-ID-00002][Error] Whitelist Validation - if minimumValues is defined for a minimum set of relTo values, then 
      ensure that @ism:releasableTo values include each member of minimum values.
      
      Failed whitelist check. 
      Document releaseableTo value(s): [<sch:value-of select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras($searchTermList))"/>]   
      Minimum required releaseableTo value(s): [<sch:value-of select="util:getSpaceSeparatedStringFromSequence(util:expandDecomposableTetras(  $releasableToMinList_tok  ))"/>]           
    </sch:assert>
  </sch:rule>
  
</sch:pattern>