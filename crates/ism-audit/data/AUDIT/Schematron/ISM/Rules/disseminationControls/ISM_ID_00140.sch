<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00140" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00140][Error] If ISM_CAPCO_RESOURCE and attribute disseminationControls contains
        the name token [NF], then attribute classification must not have a value of [U]
        
        Human Readable: NF may not be used on UNCLASSIFIED portions.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the attribute
        classification of the element and return true if it has a value of [U]. 
        Otherwise we check that the attribute disseminationControls does not
        contain the value [NF].
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00140" 
            test="
            if(not(./@ism:classification='U')) then true() else
                not(index-of(tokenize(string(./@ism:disseminationControls),' '), 'NF')>0)
            " 
            flag="error">
            [ISM-ID-00140][Error] NF may not be used on UNCLASSIFIED portions.
        </sch:assert>
    </sch:rule>
</sch:pattern>