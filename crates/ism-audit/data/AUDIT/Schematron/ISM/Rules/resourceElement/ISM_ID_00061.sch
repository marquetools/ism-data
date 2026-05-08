<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00061" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00061][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute SCIcontrols containing a value of [SI-G] then the ISM_RESOURCE_ELEMENT element’s SCIcontrols must contain [SI-G].
        
        Human Readable: USA documents having SI-G data must have SI-G at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        SCIcontrols specified with a value containing [SI-G] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement
        has attribute SCIcontrols specified with a value containing [SI-G].
    </sch:p>    
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00061" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($partSCIcontrols_tok, 'SI-G') > 0)
                then index-of($bannerSCIcontrols_tok, 'SI-G') > 0
                else true()
            " 
            flag="error">
            [ISM-ID-00061][Error] USA documents having SI-G data must have SI-G at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>