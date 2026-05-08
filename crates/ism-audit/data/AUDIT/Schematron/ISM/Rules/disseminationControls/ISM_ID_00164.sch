<?xml version="1.0" encoding="utf-8"?>
<sch:pattern id="ISM-ID-00164" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00164][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [RS],
        then attribute classification must have a value of [TS] or [S].
        
        Human Readable: USA documents with RISK SENSITIVE dissemination must
        be classified SECRET or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        classification of the element and return true if it has a value of [S] or
        [TS]. Otherwise we check that the attribute disseminationControls does not
        contain the value [RS].
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls), ' ')"/>
        <sch:assert 
            id="ISM-00164" 
            test="
            if(matches(./@ism:classification,'^(TS|S)$')) then true() else
                not(index-of($dissemTok,'RS')>0) 
            " 
            flag="error">
            [ISM-ID-00164][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [RS],
            then attribute classification must have a value of [TS] or [S].
            
            Human Readable: USA documents with RISK SENSITIVE dissemination must
            be classified SECRET or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>