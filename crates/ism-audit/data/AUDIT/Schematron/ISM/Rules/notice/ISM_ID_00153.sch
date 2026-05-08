<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00153" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00153][Error] If ISM_CAPCO_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES-NF]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES-NF].
        
        Human Readable: USA documents containing an LES-NF notice must also have LES-NF data. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute notice specified 
        with a value containing [LES-NF] and it is included in the rollup, then we make sure that 
        attribute nonICmarkings is specified with a value containing [LES-NF] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <sch:assert id="ISM-00153"
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(index-of(tokenize(string(./@ism:noticeType), ' '), 'LES-NF')>0 and not(./@ism:excludeFromRollup=true()))
            then index-of($partNonICmarkings_tok, 'LES-NF')>0
            else true()
            "
            flag="error"> 
            [ISM-ID-00153][Error] If ISM_CAPCO_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute nonICmarkings containing [LES-NF]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute notice containing [LES-NF]
            
            Human Readable: USA documents containing LES-NF data must also have an LES-NF notice.
        </sch:assert>
    </sch:rule>
</sch:pattern>
