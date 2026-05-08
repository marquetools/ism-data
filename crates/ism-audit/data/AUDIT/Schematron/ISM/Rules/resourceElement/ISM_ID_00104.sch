<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00104" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00104][Error] If ISM_CAPCO_RESOURCE and any element in the document:
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [SBU-NF]
        AND
        3. The ISM_RESOURCE_ELEMENT has attribute classification equal to [U]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU-NF].
        
        Human Readable: Unclassified USA documents having SBU-NF must have SBU-NF at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [SBU-NF] and the resourceElement has the attribute
        classification specified with a value of [U], then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value other than [SBU-NF].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00104" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
                if(index-of($partNonICmarkings_tok, 'SBU-NF') > 0 and $bannerClassification='U') 
                then (index-of($bannerNonICmarkings_tok, 'SBU-NF') > 0)
                else true()
            " 
            flag="error">
            [ISM-ID-00104][Error] Unclassified USA documents having SBU-NF must have SBU-NF at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>