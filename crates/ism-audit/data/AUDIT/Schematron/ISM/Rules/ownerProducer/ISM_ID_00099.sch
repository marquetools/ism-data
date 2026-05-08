<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00099" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE attribute ownerProducer contains [FGI], 
        it must be the only value.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Otherwise, we make sure that the current element has 
        attribute ownerProducer specified with [FGI] as its only value.
    </sch:p>
    <sch:rule context="*[@ism:ownerProducer]">
        <sch:let name="opTok" value="tokenize(string(./@ism:ownerProducer),' ')"/>
        <sch:assert 
            id="ISM-00099" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            not(index-of($opTok,'FGI')>0 and count($opTok)>1)
            " 
            flag="error">
            [ISM-ID-00099][Error] If ISM_CAPCO_RESOURCE attribute ownerProducer contains [FGI], 
            it must be the only value.
        </sch:assert>
    </sch:rule>
</sch:pattern>