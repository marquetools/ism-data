<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00072" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00072][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute atomicEnergyMarkings containing [RD] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD].
        
        Human Readable: USA documents having Restricted Data (RD) must have RD at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD] unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00072" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            not(index-of($aeaTagsFound,'RD') > 0)
            " 
            flag="error">
            [ISM-ID-00072][Error] USA documents having Restricted Data (RD) must have RD at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>