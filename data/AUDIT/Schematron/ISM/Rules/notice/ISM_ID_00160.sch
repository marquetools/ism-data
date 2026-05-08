<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00160" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00160][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice of ISM_RESOURCE_ELEMENT does contain [DoD-Dist-A]
        AND
        2. attribute disseminationControls contains any of [FOUO], [PR], [DSEN], OR [FISA]
        AND
        3. attribute atomicEnergyMarkings contains any of [DCNI] or [UCNI].
        
        Human Readable: Distribution statement A (Public Release) is incompatible 
        with [FOUO], [PR], [DCNI], [UCNI], [DSEN], OR [FISA].
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if the resourceElement 
        has attribute notice containing a value of [DoD-Dist-A] that the resourceElement's attribute
        disseminationControls does not contain values [FOUO], [PR], [DSEN], or [FISA] and attribute
        atomicEnergyMarkings does not contain values [UCNI] or [DCNI].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert id="ISM-00160"
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if(index-of($bannerNotice_tok, 'DoD-Dist-A')>0) then
            count(
                (if(index-of($bannerDisseminationControls_tok, 'FOUO')>0) then 1 else null,
                 if(index-of($bannerDisseminationControls_tok, 'PR')>0) then 1 else null,
                 if(index-of($bannerAtomicEnergyMarkings_tok, 'DCNI')>0) then 1 else null,
                 if(index-of($bannerAtomicEnergyMarkings_tok, 'UCNI')>0) then 1 else null,
                 if(index-of($bannerDisseminationControls_tok, 'DSEN')>0) then 1 else null,
                 if(index-of($bannerDisseminationControls_tok, 'FISA')>0) then 1 else null)
            )=0 else true()
            "
            flag="error"> 
            [ISM-ID-00160][Error] Distribution statement A (Public Release) is 
            incompatible with [FOUO], [PR], [DCNI], [UCNI], [DSEN], OR [FISA].
        </sch:assert>
    </sch:rule>
</sch:pattern>
