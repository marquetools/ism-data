<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00142" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00142][Error] If ISM_NSI_EO_APPLIES and attribute classification has a value other than [U]
        then attribute classifiedBy or derivativelyClassifiedBy must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Classified data including DOE data requires either an 
        original classifier or a derivative classifier be identified.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute classification with a value of [U] then we 
        return true because the rule does not apply. Otherwise we make sure that
        the resourceElement has the attribute classifiedBy or
        derivativelyClassifiedBy.
    </sch:p>
    <sch:rule context="*[@ism:classification and $ISM_NSI_EO_APPLIES]">
        <sch:assert 
            id="ISM-00142" 
            test="
            if(./@ism:classification='U') then true() else 
                ($ISM_RESOURCE_ELEMENT/@ism:classifiedBy 
                or $ISM_RESOURCE_ELEMENT/@ism:derivativelyClassifiedBy)
            " 
            flag="error">
            [ISM-ID-00142][Error] Classified data including DOE data requires either an original classifier or a derivative classifier be identified.
        </sch:assert>
    </sch:rule>
</sch:pattern>