<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00030" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [FOUO], then attribute classification must have 
        a value of [U].
        
        Human Readable: Portions marked for FOUO dissemination in a USA document must be 
        classified UNCLASSIFIED.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls without a value of 
        [FOUO] then we return true because the rule does not apply. Otherwise
        we make sure the attribute classification is specified with a value of [U] 
        on the same element.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00030" 
            test="     
            if(index-of(tokenize(string(@ism:disseminationControls),' '),'FOUO')>0)
                then @ism:classification='U'
                else true()
            " 
            flag="error">
            [ISM-ID-00030][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [FOUO], then attribute classification must have 
            a value of [U].
            
            Human Readable: Portions marked for FOUO dissemination in a USA document must be 
            classified UNCLASSIFIED.
        </sch:assert>
    </sch:rule>
</sch:pattern>