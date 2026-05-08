<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00090" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00090][Error] If ISM_CAPCO_RESOURCE and any element: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute disseminationControls containing [REL]
        Then the ISM_RESOURCE_ELEMENT must not have attribute disseminationControls containing [EYES]. 
        
        Human Readable: USA documents with any portion that is REL must not be EYES at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute disseminationControls specified
        with a value containing [REL], then we make sure that the resourceElement 
        has attribute disseminationControls specified with a value other than [EYES].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00090" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
                if(sum(for $token in $partTags return 
                        if(contains(string($token/@ism:disseminationControls), 'REL'))
                        then 1 else 0)
                ) then not(index-of($bannerDisseminationControls_tok, 'EYES')>0)
                else true()
            " 
            flag="error">
            [ISM-ID-00090][Error] USA documents with any portion that is REL must not be EYES at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>