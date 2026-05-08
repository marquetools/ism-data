<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00182" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00182][Error] If ISM_CAPCO_RESOURCE and element’s 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [DCNI].
        
        Human Readable: DCNI may only be used on Unclassified portions.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check the classification
        attribute of the current element. If it has a value of [U] we return true since 
        this rule only applies to classified elements. If it is not [U] then we check
        that the attribute atomicEnergyMarkings does not have a value of [DCNI].
    </sch:p>
    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        <sch:assert 
            id="ISM-00182" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else   
            if(./@ism:classification='U') then true() else
                not(index-of(tokenize(string(./@ism:atomicEnergyMarkings), ' '),'DCNI')>0)
            " 
            flag="error">
            [ISM-ID-00182][Error] DCNI may only be used on Unclassified portions.
        </sch:assert>
    </sch:rule>
</sch:pattern>