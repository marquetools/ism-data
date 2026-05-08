<?xml version="1.0" encoding="UTF-8"?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!--
    This abstract pattern verifies that all values of a given context match a value in a given list. The 
    calling rule must pass the context that will provide a list of values to check, list of values from configuration 
    file to match, and an error message.
    
    $context        := the context in which the search values exists
    $list           := the list in which the target element value should exist
    $errMsg         := the error message text to display when the assertion fails
    
    Example usage:
    Inside an ntk:RequiresAllOf structure, ensure that all ntk:AccessProfile values exist in whitelist
    
    <sch:pattern is-a="AllValuesExistsInList" id="WLAccessPolicy-ID-00001" xmlns:sch="http://purl.oclc.org/dsdl/schematron">  
        <sch:param name="context"   
            value="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"/>
        <sch:param name="list" value="$policyList"/>
        <sch:param name="errMsg" value="'
    		[WLAccessPolicy-ID-00001][Error] NTK AccessPolicy Whitelist Validation -
    		all ntk:AccessPolicy values in document must exist in the whitelist.'"/>
    </sch:pattern>
    
-->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" abstract="true" id="AllValuesExistInList">

   <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">This abstract pattern verifies that a value at a given context matches fome value in a list
      using regular expression matching. The calling rule must pass the context, search term list, attribute value to
      check, and an error message.</sch:p>

   <sch:rule id="AllValuesExistInList-R1" context="$context">
      <!--<sch:let name="fullSearchTermList" value="$context"/>-->
      <!--<sch:let name="initialItem" value="util:getFirstItemFromSequence($list)"/>-->
      <sch:assert test="(                   
                           (matches(util:getFirstItemFromSequence($list),'\*'))
                           or                   
                           ( every $searchTerm in $context satisfies some $term in $list satisfies (matches ($searchTerm , $term)) )
                         )" flag="error" role="error">
         <sch:value-of select="$errMsg"/>
         
         Document Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($context)"/>]
         
         Whitelist Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($list)"/>]
      </sch:assert>
   </sch:rule>
</sch:pattern>