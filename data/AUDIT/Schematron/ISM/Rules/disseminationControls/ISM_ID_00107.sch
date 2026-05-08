<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00107" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00107][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [IMC] then attribute classification must have a 
        value of [TS] or [S].
        
        Human Readable:  IMCON data is SECRET (S), but may appear with S or TOP SECRET data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        classification of the element and return true if it has a value of [S] or
        [TS]. Otherwise we check that the attribute disseminationControls does not
        contain the value [IMC].
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00107" 
            test="
            if(matches(./@ism:classification,'^(TS|S)$')) then true() else
                not(index-of(tokenize(string(./@ism:disseminationControls), ' '),'IMC')>0)
            " 
            flag="error">
            [ISM-ID-00107][Error] IMCON data is SECRET (S), but may appear with S or TOP SECRET data.
        </sch:assert>
    </sch:rule>
</sch:pattern>