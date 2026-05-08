<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00122" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00122][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
        classification must have a value of [TS] or [S].
        
        Human Readable: A USA document with KLONDIKE data must be classified SECRET or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [KDK], then we make sure that attribute classification
        has a value [TS] or [S].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00122" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else   
            not(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'KDK')>0 
                and not(matches(./@ism:classification,'^(TS|S)$'))
            )
            " 
            flag="error">
            [ISM-ID-00122][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
            classification must have a value of [TS] or [S].
            
            Human Readable: A USA document with KLONDIKE data must be classified SECRET or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>