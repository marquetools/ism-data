<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00060" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00060][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute SCIcontrols containing a value of [SI] then the ISM_RESOURCE_ELEMENT element’s SCIcontrols must contain [SI].
        
        Human Readable: USA documents having SI data must have SI at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute 
        SCIcontrols specified with a value containing [SI] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement
        has attribute SCIcontrols specified with a value containing [SI].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00060" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($partSCIcontrols_tok, 'SI') > 0)
                then index-of($bannerSCIcontrols_tok, 'SI') > 0
                else true()
            " 
            flag="error">
            [ISM-ID-00060][Error] USA documents having SI data must have SI at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>