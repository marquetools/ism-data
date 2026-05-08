<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00044" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
        classification must have a value of [TS].
        
        Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data 
        must be classified TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G], then we make sure that attribute classification
        has a value of [TS].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00045" 
            test="if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of(tokenize(string(./@ism:SCIcontrols),' '),'SI-G')>0 
                and not(matches(./@ism:classification,'^TS$'))
            ) then false() else true()
            " 
            flag="error">
            [ISM-ID-00044][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G], then attribute 
            classification must have a value of [TS].
            
            Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data 
            must be classified TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>