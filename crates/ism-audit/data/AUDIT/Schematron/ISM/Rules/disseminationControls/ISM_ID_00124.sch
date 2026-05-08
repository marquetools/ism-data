<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00124" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00124][Warning] If ISM_CAPCO_RESOURCE and
        1. Attribute ownerProducer does not contain [USA].
        AND
        2. Attribute disseminationControls contains [RELIDO]
        
        Human Readable: RELIDO is not authorized for non-US portions.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        ownerProducer for not having a value of [USA] and that the attribute
        disseminationControls contains a value of [RELIDO] then we return false
        because the resource is not in compliance with the rule.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00124" 
            test="
            if(not(index-of(tokenize(string(./@ism:ownerProducer),' '),'USA')>0)
               and index-of(tokenize(string(./@ism:disseminationControls),' '), 'RELIDO')>0) 
                then false() 
                else true()
            " 
            flag="warning">
            [ISM-ID-00124][Warning] RELIDO is not authorized for non-US portions.
        </sch:assert>
    </sch:rule>
</sch:pattern>