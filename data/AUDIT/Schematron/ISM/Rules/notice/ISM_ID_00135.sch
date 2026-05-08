<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00135" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00135][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
        AND
        2. Any element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [RD]
        
        Human Readable: USA documents containing an RD notice must also have RD data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If  the current element is the resourceElement
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [RD], then we make sure that attribute atomicEnergyMarkings is specified 
        with a value containing [RD] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <sch:assert 
            id="ISM-00135" 
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else
            if(index-of(tokenize(string(./@ism:noticeType), ' '), 'RD')>0 and not(./@ism:excludeFromRollup=true()))
            then index-of($partAtomicEnergyMarkings_tok, 'RD')>0 
                else true()
            " 
            flag="warning">
            [ISM-ID-00135][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD]
            AND
            2. Any element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [RD]
            
            Human Readable: USA documents containing RD data must also have an RD notice.
        </sch:assert>
    </sch:rule>
</sch:pattern>