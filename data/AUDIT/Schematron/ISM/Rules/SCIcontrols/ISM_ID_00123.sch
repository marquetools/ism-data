<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00123" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
        disseminationControls must contain the name token [NF].
        
        Human Readable: A USA document containing KLONDIKE data must also be marked for NO FOREIGN dissemination.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [KDK], then we make sure that attribute disseminationControls contains
        the value [NF].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00123" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else   
            if(index-of(tokenize(string(./@ism:SCIcontrols), ' '),'KDK')>0 
                and not( index-of(tokenize(string(./@ism:disseminationControls), ' '),'NF'))
            ) then false() else true()
            " 
            flag="error">
            [ISM-ID-00123][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [KDK], then attribute 
            disseminationControls must contain the name token [NF].
            
            Human Readable: A USA document containing KLONDIKE data must also be marked for NO FOREIGN dissemination.
        </sch:assert>
    </sch:rule>
</sch:pattern>