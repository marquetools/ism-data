<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00073" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00073][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute atomicEnergyMarkings containing [RD-CNWDI] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD-CNWDI].
        
        Human Readable: USA documents having Restricted CNWDI Data must have Restricted CNWDI Data at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD-CNWDI] unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD-CNWDI].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00073" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            not(index-of($aeaTagsFound,'RD-CNWDI') > 0)
            " 
            flag="error">
            [ISM-ID-00073][Error] USA documents having Restricted CNWDI Data must have Restricted CNWDI Data at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>