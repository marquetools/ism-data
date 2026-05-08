<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00138" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00138][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [DS]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [DS]
        
        Human Readable: USA documents containing a DS notice must also have DS data. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [DS] and is not excluded from the rollup, then we make sure that 
        attribute nonICmarkings is specified with a value containing [DS] in one of the 
        portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <sch:assert id="ISM-00138"
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(index-of(tokenize(string(./@ism:noticeType), ' '), 'DS')>0 and not(./@ism:excludeFromRollup=true()))
                then index-of($partNonICmarkings_tok, 'DS')>0
                else true()
            "
            flag="warning"> 
            [ISM-ID-00138][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [DS]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [DS]
            
            Human Readable: USA documents containing DS data must also have a DS notice.
        </sch:assert>
    </sch:rule>
</sch:pattern>
