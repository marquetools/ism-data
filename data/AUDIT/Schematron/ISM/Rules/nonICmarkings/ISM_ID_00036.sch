<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00036" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00036][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings 
        contains the name token [SC], then attribute classification must have a 
        value of [TS], [S], or [C].        
        
        Human Readable: SC data must be marked CONFIDENTIAL, SECRET or TOP SECRET in USA documents.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check if the attribute
        disseminationControls contains the value [SC] and if it does we check that
        the classification attribute has a value of [C], [S], or [TS].
    </sch:p>
    <sch:rule context="*[@ism:nonICmarkings]">
        <sch:assert 
            id="ISM-00036" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if(index-of(tokenize(string(./@ism:nonICmarkings), ' '),'SC')>0)
                then matches(./@ism:classification,'^(TS|S|C)$')
                else true()
            " 
            flag="error">
            [ISM-ID-00036][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings 
            contains the name token [SC], then attribute classification must have a 
            value of [TS], [S], or [C].        
            
            Human Readable: SC data must be marked CONFIDENTIAL, SECRET or TOP SECRET in USA documents.
        </sch:assert>
    </sch:rule>
</sch:pattern>