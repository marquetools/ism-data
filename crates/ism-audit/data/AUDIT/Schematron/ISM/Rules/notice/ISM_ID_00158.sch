<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00158" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00158][Error] If ISM_CAPCO_RESOURCE and:
        1. ISM_DoD5230_24_Applies
        AND
        2. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        3. The attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
        
        Human Readable: All classified documents that claim compliance with DoD5230.24 must use one of DoD 
        distribution statements B, C, D, E, or F.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If DoD-5230-24 does not apply then the rule does not apply
        and we return true. If the resource is Unclassified then the rule does not apply
        and we return true. Otherwise, we make sure that the resourceElement attribute notice 
        does not contain a value of [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], 
        or [DoD-Dist-F].
    </sch:p>
    <sch:rule context="*[@ism:resourceElement=true()]">
        <sch:assert id="ISM-00158"
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if(not($ISM_DOD5230_24_APPLIES)) then true() else
            if(./@ism:classification='U') then true() else
            if(
               count(
                   (if(index-of($bannerNotice_tok, 'DoD-Dist-B')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-C')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-D')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-E')>0) then 1 else null,
                    if(index-of($bannerNotice_tok, 'DoD-Dist-F')>0) then 1 else null)
               )=0
            ) then false() 
              else true()
            "
            flag="error"> 
            [ISM-ID-00158][Error] All classified documents that claim compliance with DoD5230.24 must use one of DoD 
            distribution statements B, C, D, E, or F.
        </sch:assert>
    </sch:rule>
</sch:pattern>
