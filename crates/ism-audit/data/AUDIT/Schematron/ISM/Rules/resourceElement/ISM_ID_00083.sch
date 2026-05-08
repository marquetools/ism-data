<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00083" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00083][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document have the attribute nonICmarkings containing [SINFO] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SINFO].
        
        Human Readable: USA documents having SINFO Data must have SINFO at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document or the banner is classified then the 
        rule does not apply and we return true. If any element has attribute nonICmarkings 
        specified with a value containing [SINFO] and does not have attribute 
        excludeFromRollup set to true, then we make sure that the resourceElement 
        also has attribute nonICmarkings specified with a value containing [SINFO].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00083" 
            test="
            if(not($ISM_CAPCO_RESOURCE) or not(matches(./@ism:classification,'^U$'))) then true() else
            if(index-of($partNonICmarkings_tok, 'SINFO') > 0)
            then (index-of($bannerNonICmarkings_tok, 'SINFO') > 0)
            else true()
            " 
            flag="error">
            [ISM-ID-00083][Error] USA documents having SINFO Data must have SINFO at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>