<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00065" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00065][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceProtected containing any value then the ISM_RESOURCE_ELEMENT must have FGIsourceProtected with a value.
        
        Human Readable: USA documents having FGI Protected data must have FGI Protected at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute FGIsourceProtected specified 
        with a non-empty value and does not have attribute excludeFromRollup set to true, 
        then we make sure that the banner has attribute FGIsourceProtected specified with 
        a non-empty value.
    </sch:p>  
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00065" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not(empty($partFGIsourceProtected))) then $bannerFGIsourceProtected else true()
            " 
            flag="error">
            [ISM-ID-00065][Error] USA documents having FGI Protected data must have FGI Protected at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>