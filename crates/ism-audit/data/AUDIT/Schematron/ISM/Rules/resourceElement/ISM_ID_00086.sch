<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00086" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00086][Error] If ISM_CAPCO_RESOURCE and any element in the document:
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [ND]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [ND].
        
        Human Readable: USA documents having ND Data must have ND at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [ND] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value containing [ND].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00086" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($partNonICmarkings_tok, 'ND')>0)
            then index-of($bannerNonICmarkings_tok, 'ND') > 0
            else true()
            " 
            flag="error">
            [ISM-ID-00086][Error] USA documents having ND Data must have ND at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>