<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00071" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00071][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute disseminationControls containing [PR] then the ISM_RESOURCE_ELEMENT must have 
        disseminationControls containing [PR].
        
        Human Readable: USA documents having PROPIN data must have PROPIN at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified
        with a value containing [PR] unless the resourceElement also has attribute
        disseminationControls specified with a value containing [PR].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00071" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            not(index-of($dcTagsFound,'PR') > 0)
            " 
            flag="error">
            [ISM-ID-00071][Error] USA documents having PROPIN data must have PROPIN at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>