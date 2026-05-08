<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00068" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00068][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document have the attribute disseminationControls containing [IMC] then the ISM_RESOURCE_ELEMENT must have 
        disseminationControls containing [IMC].
        
        Human Readable: USA documents having IMCON data must have IMCON at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. We make sure that no element that does not have attribute excludeFromRollup 
        set to true has attribute disseminationControls specified with a value containing [IMC] 
        unless the resourceElement also has attribute disseminationControls specified with a value 
        containing [IMC].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00068" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            not(index-of($dcTagsFound,'IMC') > 0)
            " 
            flag="error">
            [ISM-ID-00068][Error] USA documents having IMCON data must have IMCON at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>