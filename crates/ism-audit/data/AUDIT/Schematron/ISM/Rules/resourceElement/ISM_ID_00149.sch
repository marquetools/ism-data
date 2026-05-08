<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00149" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00149][Error] If ISM_CAPCO_RESOURCE and 
        1. Any element in the document meets ISM_CONTRIBUTES in the document has 
           the attribute nonICmarkings contain [LES-NF]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        THEN the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES-NF]
        
        Human Readable: Unclassified USA documents having LES-NF must have LES-NF at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value of [U], then we make sure that the resourceElement has attribute nonICmarkings
        specified with a value containing [LES-NF].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00149" 
            test="
                if(not($ISM_CAPCO_RESOURCE)) then true() else
                    if(index-of($partNonICmarkings_tok, 'LES-NF') > 0 and $bannerClassification='U')
                    then (index-of($bannerNonICmarkings_tok, 'LES-NF') > 0)
                    else true()
            " 
            flag="error">
            [ISM-ID-00149][Error] Unclassified USA documents having LES-NF data must have LES-NF at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>