<?xml version="1.0" encoding="UTF-8"?>
<!--
    
    This abstract pattern checks to see if an all attributes of an list exist in a whitelist.

    $context        := the context in which the searchValue exists
    $searchTermList := the set of values which you want to verify is in the list
    $list           := the list in which to search for the searchValue
    $errMsg         := the error message text to display when the assertion fails
    
    Example usage:
    <sch:pattern is-a="ValidateTokensExistInWhitelist" id="WLReleaseableTo_ID_00001" xmlns:sch="http://purl.oclc.org/dsdl/schematron">  
        <sch:param name="context"    value="*[@ism:releasableTo]"/>
        <sch:param name="searchTermList" value="@ism:releasableTo"/>
        <sch:param name="list" value="$releasableToList_tok"/>
        <sch:param name="errMsg"
                    value="'   [WLReleaseableTo-ID-00001][Error] Whitelist Validation - each @ism:releasableTo value in document must exist in whitelist.'"/>
    </sch:pattern>
    
-->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" abstract="true" id="ValidateTokensExistInWhitelist">

    <sch:p class="codeDesc">This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</sch:p>

    <sch:rule id="ValidateTokensExistInWhitelist-R1" context="$context">
        
        <sch:assert test="(matches(util:getFirstItemFromSequence($list),'\*'))  or ( ( matches(util:getFirstItemFromSequence($list),'\*') ) or (every $searchTerm in tokenize(util:getSpaceSeparatedStringFromSequence($searchTermList), ' ') satisfies             some $Term in $list satisfies (matches (normalize-space($searchTerm), concat('^', $Term ,'$'))) )   )   " flag="error" role="error">
            <sch:value-of select="$errMsg"/>  Document Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($searchTermList)"/>]   Whitelist Value(s): [<sch:value-of select="util:getCommaSeparatedStringFromSequence($list)"/>]
            
        </sch:assert>
        
        
    </sch:rule>
</sch:pattern>