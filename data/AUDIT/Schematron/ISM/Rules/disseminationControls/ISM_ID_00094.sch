<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00094" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00094][Error] ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [REL], then attribute classification must not 
        have a value of [U].
        
        Human Readable: REL may not be used on UNCLASSIFIED portions.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the classification
        attribute of the current element. If it does not have value of [U] we return 
        true since this rule only applies to unclassified elements. If it is not [U] 
        then we check that the attribute disseminationControls does not have a value 
        of [REL].
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00094" 
            test="
            if(not(./@ism:classification='U')) then true() else
                not(index-of(tokenize(string(./@ism:disseminationControls), ' '),'REL')>0)
            "
            flag="error">
            [ISM-ID-00094][Error] REL may not be used on UNCLASSIFIED portions.
        </sch:assert>
    </sch:rule>
</sch:pattern>