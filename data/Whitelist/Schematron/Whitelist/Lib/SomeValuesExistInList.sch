<?xml version="1.0" encoding="UTF-8"?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!--
    This abstract pattern verifies that some values of a given context match a value in a given list. The 
    calling rule must pass the context that will provide a list of values to check, list of values from configuration 
    file to match, and an error message.
    
    $context        := the context in which the search values exists
    $list           := the list in which the target element value should exist
    $errMsg         := the error message text to display when the assertion fails
    
    Example usage:
    Inside a ntk:RequiresAnyOf structure, ensure that at least one ntk:AccessProfile value exists in whitelist. 
    
    <sch:pattern is-a="ValueExistsInList" id="IWLAccessPolicy-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">  
        <sch:param name="context" value="//ntk:RequiresAnyOf/ntk:AccessProfileList/ntk:AccessProfile/ntk:AccessPolicy"/>
        <sch:param name="list" value="$policyList"/>
        <sch:param name="errMsg" value="'
    		[WLAccessPolicy-ID-00002][Error] NTK AccessPolicy Whitelist Validation -
    		at least one ntk:AccessPolicy value in document must exist in the whitelist.'
        '"/>
    </sch:pattern>
    
-->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" abstract="true" id="SomeValuesExistInList">

   <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">This abstract pattern verifies 
      that the values of child elements at a given context match some value in a list. The calling rule must pass the 
      context, child element name to build search term list, list of values from configuration file, and an error message.</sch:p>

   <sch:rule id="SomeValuesExistInList-R1" context="$context">
      <sch:assert test="(
                           (matches(util:getFirstItemFromSequence($list),'\*'))  
                           or  
                           (some $searchTerm in $context satisfies some $term in $list satisfies (matches ($searchTerm , $term)))
                         )" flag="error" role="error">
         <sch:value-of select="$errMsg"/>
         
         Document Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($context)"/>]
         
         Whitelist Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($list)"/>]
      </sch:assert>
   </sch:rule>
</sch:pattern>