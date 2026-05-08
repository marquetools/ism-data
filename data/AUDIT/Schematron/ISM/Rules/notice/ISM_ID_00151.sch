<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00151" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00151][Warning] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES]    
        
        Human Readable: USA documents containing an LES notice must also have LES data. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [LES] and it is included in the rollup, then we make sure that 
        attribute nonICmarkings is specified with a value containing [LES] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <sch:assert id="ISM-00151"
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else
            if(index-of(tokenize(string(./@ism:noticeType), ' '), 'LES')>0 and not(./@ism:excludeFromRollup=true()))
                then index-of($partNonICmarkings_tok, 'LES')>0
                else true()
            "
            flag="warning"> 
            [ISM-ID-00151][Warning] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES]
            
            Human Readable: USA documents containing LES data must also have an LES notice. 
        </sch:assert>
    </sch:rule>
</sch:pattern>
