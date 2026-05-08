<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00162" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00162][Error] If ISM_CAPCO_RESOURCE and 
        1. ISM_DoD5230_24_Applies
        AND
        2. Attribute notice of ISM_RESOURCE_ELEMENT contains more than one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All USA documents that claim compliance with DoD5230.24 must have only 1 distribution statement
        for the entire document.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If ISM_DoD5230_24_Applies does not apply to the document
        then the rule does not apply and we return true. Otherwise, we make sure that
        the resourceElement has attribute notice specified with a value containing
        only one of [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], 
        [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00155" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if(not($ISM_DOD5230_24_APPLIES)) then true() else
            not(count(
                (   if(index-of($bannerNotice_tok, 'DoD-Dist-A')>0) then 1 else null, 
                    if(index-of($bannerNotice_tok, 'DoD-Dist-B')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-C')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-D')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-E')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-F')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-X')>0) then 1 else null)
                 )>1)
            " 
            flag="error">
            [ISM-ID-00162][Error] All USA documents that claim compliance with DoD5230.24 must have only 1 distribution statement
            for the entire document.
        </sch:assert>
    </sch:rule>
</sch:pattern>