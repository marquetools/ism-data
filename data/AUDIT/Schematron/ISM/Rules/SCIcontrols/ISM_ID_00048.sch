<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00048" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [HCS], then attribute 
        classification must have a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing HCS data must be classified CONFIDENTIAL, SECRET, or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [HCS], then we make sure that attribute classification
        has a value of [TS], [S], or [C].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00048" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(
                index-of(tokenize(string(./@ism:SCIcontrols), ' '),'HCS')>0 and 
                not(matches(./@ism:classification,'^(TS|S|C)$'))
            ) then false() else true()      
            " 
            flag="error">
            [ISM-ID-00048][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [HCS], then attribute 
            classification must have a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing HCS data must be classified CONFIDENTIAL, SECRET, or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>