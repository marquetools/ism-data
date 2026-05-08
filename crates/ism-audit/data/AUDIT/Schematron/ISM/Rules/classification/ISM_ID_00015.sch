<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00015" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00015][Error] If ISM_CAPCO_RESOURCE and attribute 
        classification has a value of [U], then attributes releasableTo, SARIdentifier, and SCIcontrols 
        must not be specified.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute classification with a value of [U] then we do 
        not have attributes releasableTo, SARIdentifier, or SCIcontrols on the 
        same element.
    </sch:p>
    <sch:rule context="*[@ism:classification and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00015" 
            test="
            if(./@ism:classification='U'
               and (./@ism:releasableTo or ./@ism:SARIdentifier 
                    or ./@ism:SCIcontrols))
                then false() 
                else true()
            " 
            flag="error">
            [ISM-ID-00015][Error] If ISM_CAPCO_RESOURCE and attribute 
            classification has a value of [U], then attributes releasableTo, SARIdentifier, and SCIcontrols 
            must not be specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>