<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00084" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00084][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute nonICmarkings containing [DS] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [DS]. 
        
        Human Readable: USA documents having DS Data must have DS at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [DS] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        also has attribute nonICmarkings specified with a value containing [DS].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00084" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($partNonICmarkings_tok, 'DS') > 0)
            then (index-of($bannerNonICmarkings_tok, 'DS') > 0)
            else true()
            " 
            flag="error">
            [ISM-ID-00084][Error] USA documents having DS Data must have DS at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>