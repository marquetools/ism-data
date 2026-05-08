<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00016" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
        classification has a value of [U], then attributes classificationReason, classifiedBy, 
        derivativelyClassifiedBy, declassDate, declassEvent, declassException and 
        derivedFrom must not be specified.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute classification with a value of [U] then we do 
        not have attributes classifiedBy, declassDate,
        declassEvent, declassException, derivativelyClassifiedBy, or derivedFrom 
        on the same element.
    </sch:p>
    <sch:rule context="*[@ism:classification and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00016" 
            test="
            if(matches(./@ism:classification,'^U$') 
               and (./@ism:classificationReason 
                   or ./@ism:classifiedBy 
                   or ./@ism:declassDate 
                   or ./@ism:declassEvent 
                   or ./@ism:declassException 
                   or ./@ism:derivativelyClassifiedBy 
                   or ./@ism:derivedFrom)) 
            then false() else true()
            " 
            flag="error">
            [ISM-ID-00016][Error] If ISM_CAPCO_RESOURCE and attribute 
            classification has a value of [U], then attributes classificationReason, classifiedBy, 
            derivativelyClassifiedBy, declassDate, declassEvent, declassException, 
            and derivedFrom must not be specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>