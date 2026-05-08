<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00152" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00152][Error] If ISM_CAPCO_RESOURCE and:
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES-NF]
        AND
        2. No element meeting ISM_CONTRIBUTES in the document has notice containing [LES-NF]
        
        Human Readable: USA documents containing LES-NF data must also have an LES-NF notice. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document and the element is not excluded from the rollup
        then the rule does not apply and we return true. If the current element specifies attribute 
        nonICmarkings with a value containing [LES-NF], then we make sure that attribute notice is 
        specified with a value containing [LES-NF] in one of the portions of the document.
    </sch:p>
    <sch:rule context="*[@ism:nonICmarkings]">
        <sch:assert 
            id="ISM-00152"
            test="
            if(not($ISM_CAPCO_RESOURCE) or ./@ism:excludeFromRollup=true()) then true() else 
            if(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) then true() else
            if(index-of(tokenize(string(./@ism:nonICmarkings), ' '), 'LES-NF')>0) 
            then index-of($partNotice_tok, 'LES-NF')>0
            else true()
            " 
            flag="error">
            [ISM-ID-00152][Error] If ISM_CAPCO_RESOURCE and:
            1. Any element meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES-NF]
            AND
            2. No element meeting ISM_CONTRIBUTES in the document has notice containing [LES-NF]
            
            Human Readable: USA documents containing LES-NF data must also have an LES-NF notice. 
        </sch:assert>
    </sch:rule>
</sch:pattern>