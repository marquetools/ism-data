<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00045" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00045][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
        disseminationControls must contain the name token [OC].
        
        Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data must 
        be marked for ORIGINATOR CONTROLLED dissemination.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G], then we make sure that attribute disseminationControls
        contains the value [OC].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00045" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of(tokenize(string(./@ism:SCIcontrols),' '),'SI-G')>0)
                then index-of(tokenize(string(./@ism:disseminationControls),' '), 'OC')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00045][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
            disseminationControls must contain the name token [OC].
            
            Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data must 
            be marked for ORIGINATOR CONTROLLED dissemination.
        </sch:assert>
    </sch:rule>
</sch:pattern>