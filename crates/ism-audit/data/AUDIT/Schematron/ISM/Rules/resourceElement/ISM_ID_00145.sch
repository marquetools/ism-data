<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00145" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00145][Error] If ISM_CAPCO_RESOURCE and any element in the document: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [LES]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [LES-NF]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: USA documents having LES and not having LES-NF must have LES at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES] and no element has attribute nonICmarkings specified 
        with a value containing [LES-NF], then we make sure that the resourceElement has attribute 
        nonICmarkings specified with a value containing [LES].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00145" 
            test="
                if(not($ISM_CAPCO_RESOURCE)) then true() else
                    if(index-of($partNonICmarkings_tok, 'LES') > 0 and not(index-of($partNonICmarkings_tok, 'LES-NF') > 0))
                    then (index-of($bannerNonICmarkings_tok, 'LES') > 0)
                    else true()
            " 
            flag="error">
            [ISM-ID-00145][Error] USA documents having LES and not having LES-NF must have LES at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>