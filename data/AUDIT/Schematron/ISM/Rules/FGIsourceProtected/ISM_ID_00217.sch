<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00217" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected contains [FGI], 
        it must be the only value.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Otherwise, we make sure that the current element has 
        attribute FGIsourceProtected specified with [FGI] as its only value.
    </sch:p>
    <sch:rule context="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]">
        <sch:let name="opTok" value="tokenize(string(@ism:FGIsourceProtected),' ')"/>
        <sch:assert 
            id="ISM-00217" 
            test="
            not(index-of($opTok,'FGI')>0 and count($opTok)>1)
            " 
            flag="error">
            [ISM-ID-00217][Error] If ISM_CAPCO_RESOURCE attribute FGIsourceProtected contains [FGI], 
            it must be the only value.
        </sch:assert>
    </sch:rule>
</sch:pattern>