<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00136" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00136][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [FRD]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [FRD]
        
        Human Readable: USA documents containing an FRD notice must also have FRD data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [FRD], then we make sure that attribute atomicEnergyMarkings is specified 
        with a value containing [FRD] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <sch:assert id="ISM-00136"
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(index-of(tokenize(string(./@ism:noticeType), ' '), 'FRD')>0 and not(./@ism:excludeFromRollup=true()))
                then index-of($partAtomicEnergyMarkings_tok, 'FRD')>0 
                else true()
            "
            flag="warning"> 
            [ISM-ID-00136][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [FRD]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [FRD]
            
            Human Readable: USA documents containing FRD data must also have an FRD notice.
        </sch:assert>
    </sch:rule>
</sch:pattern>
