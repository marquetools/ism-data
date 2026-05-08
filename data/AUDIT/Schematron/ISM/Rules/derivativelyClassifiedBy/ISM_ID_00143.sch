<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00143" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00143][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute derivedFrom must be specified. 
        
        Human Readable: Derivatively Classified data including DOE data requires a derived from value to be identified.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the resource then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute derivativelyClassifiedBy then we also have the
        attribute derivedFrom on the same element.
    </sch:p>
    <sch:rule context="*[@ism:derivativelyClassifiedBy and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00143" 
            test="./@ism:derivedFrom" 
            flag="error">
            [ISM-ID-00143][Error] Derivatively Classified data including DOE data requires a derived from value to be identified.
        </sch:assert>
    </sch:rule>
</sch:pattern>