<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   This abstract pattern checks to see if an attribute of an element exists in a blacklist or matches the pattern defined by the list.
   
   $context        := the context in which the searchValue exists
   $searchTermList := the set of values which verify against the blacklist
   $list           := the blacklist values
   $errMsg         := the error message text to display when the assertion fails
   
   <sch:param name="context"    value="*[($FGIsourceProtectedListType = 'blacklist') and @ism:FGIsourceProtected]"/>
   <sch:param name="searchTermList" value="@ism:FGIsourceProtected"/>
   <sch:param name="list" value="$FGIsourceProtectedList_tok"/>
   <sch:param name="errMsg"
              value="'   [WLFGIsourceProtected-ID-00002][Error] Blacklist Validation -  @ism:FGIsourceProtected values in document must not exist in blacklist.'"/>
-->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" abstract="true" id="ValidateTokenValuesNotInBlacklist">
  
  <sch:p class="codeDesc">This abstract pattern checks to see if an attribute of an element exists
    in a list or matches the pattern defined by the list. The calling rule must pass the
    context, search term list, attribute value to check, and an error message.</sch:p>
  
  <sch:rule id="ValidateTokenValuesNotInBlacklist-R1" context="$context">
    <sch:assert test="not(util:containsAnyOfTheTokens((normalize-space(string(util:getSpaceSeparatedStringFromSequence($searchTermList)))), ($list)))" flag="error" role="error">
      <sch:value-of select="$errMsg"/>  Document Value(s): [<sch:value-of select="util:getSpaceSeparatedStringFromSequence($searchTermList)"/>]   
                                        Blacklist Value(s): [<sch:value-of select="util:getSpaceSeparatedStringFromSequence($list)"/>]
      
    </sch:assert>
  </sch:rule>
</sch:pattern>