<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00129" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00129][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [IMC]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [IMC]
        
        Human Readable: USA documents containing IMC data must also have an IMC notice.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element has attribute disseminationControls
        specified with a value containing [IMC], then we make sure that attribute notice is specified 
        with a value containing [IMC] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls]">
        <sch:assert 
            id="ISM-00129" 
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(index-of(tokenize(string(./@ism:disseminationControls), ' '), 'IMC')>0) 
                then index-of($partNotice_tok, 'IMC')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00129][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [IMC]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [IMC]
            
            Human Readable: USA documents containing IMC data must also have an IMC notice.
        </sch:assert>
    </sch:rule>
</sch:pattern>