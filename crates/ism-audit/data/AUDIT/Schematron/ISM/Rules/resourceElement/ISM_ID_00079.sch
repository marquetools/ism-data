<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00079" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00079][Error] If ISM_CAPCO_RESOURCE and ISM_RESOURCE_ELEMENT element’s classification 
        has the value of [U] and any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing 
        [UCNI] then the ISM_RESOURCE_ELEMENT must have atomicEnergyMarkings containing [UCNI].
        
        Human Readable: Unclassified USA documents having UCNI Data must have UCNI at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification specified
        with a value other than [U] then the rule does not apply and we return true. 
        Otherwise, we make sure that no element has attribute atomicEnergyMarkings specified
        with a value containing [UCNI] and does not have attribute excludeFromRollup set to true,
        unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [UCNI].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00079" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not($bannerClassification='U')) then true() 
                else not(index-of($aeaTagsFound,'UCNI') > 0)
            " 
            flag="error">
            [ISM-ID-00079][Error] Unclassified USA documents having UCNI Data must have UCNI at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>