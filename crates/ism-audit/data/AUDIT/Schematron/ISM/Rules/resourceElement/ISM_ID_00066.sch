<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00066" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00066][Error] If ISM_CAPCO_RESOURCE and: 
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FOUO]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing [SBU], [SBU-NF], [LES], [LES-NF]
        
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [FOUO].
        
        Human Readable: USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
        FOUO at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document, then the rule does not apply
        and we return true. Verify that this is actually the ISM_RESOURCE_ELEMENT
        If the resourceElement has attribute classification specified
        with a value other than [U], then the rule does not apply and we return true. If the
		banner has attribute disseminationControls specified with a value containing [FOUO], 
		or no element has attribute disseminationControls specified with value containing [FOUO], 
		then the rule does not apply and we return true. Otherwise, we make sure that an 
		element has attribute nonICmarkings specified with a value of [SBU], [SBU-NF], [LES], 
		or [LES-NF]. 
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00066" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not($bannerClassification='U')) then true() else
                if(not(index-of($dcTagsFound,'FOUO')>0)) then true() else
                    index-of($partNonICmarkings_tok,'SBU')>0 
                    or index-of($partNonICmarkings_tok,'SBU-NF')>0
                    or index-of($partNonICmarkings_tok,'LES')>0 
                    or index-of($partNonICmarkings_tok,'LES-NF')>0
            "
            flag="error">
            [ISM-ID-00066][Error] USA Unclassified documents having FOUO data and not having SBU, SBU-NF, LES, or LES-NF must have 
            FOUO at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>