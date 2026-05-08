<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00057" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00057][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [U] then no element meeting ISM_CONTRIBUTES in the document may have a classification attribute of [R].
        
        Human Readable: USA UNCLASSIFIED documents cannot have RESTRICTED data. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply and 
        we return true. If the resourceElement has attribute classification specified 
        with a value of [U], then we make sure that no portion has attribute 
        classification specified with a value of [R].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00057" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not(./@ism:classification='U')) then true() else
            not(index-of($partClassification_tok, 'R')>0)
            " 
            flag="error">
            [ISM-ID-00057][Error] USA UNCLASSIFIED documents cannot have RESTRICTED data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>