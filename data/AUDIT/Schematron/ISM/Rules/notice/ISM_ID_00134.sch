<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00134" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00134][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [DS]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [DS]
        
        Human Readable: USA documents containing DS data must also have a DS notice.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute nonICmarkings specified 
        with a value containing [DS], then we make sure that attribute notice is specified 
        with a value containing [DS] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:nonICmarkings]">
        <sch:assert 
            id="ISM-00134" 
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'DS')>0) 
                then index-of($partNotice_tok, 'DS')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00134][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [DS]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has the attribute notice containing [DS]
            
            Human Readable: USA documents containing DS data must also have a DS notice.
        </sch:assert>
    </sch:rule>
</sch:pattern>