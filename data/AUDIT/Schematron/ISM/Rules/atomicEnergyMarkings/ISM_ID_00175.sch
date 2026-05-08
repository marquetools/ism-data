<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00175" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00175][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
        classification must have a value of [TS] or [S].
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings without a value of 
        [RD-CNWDI] then we return true because the rule does not apply. Otherwise
        we make sure the attribute classification is specified with a value of [S] 
        or [TS] on the same element.
    </sch:p>
    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        <sch:assert 
            id="ISM-00175" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not(index-of(tokenize(string(./@ism:atomicEnergyMarkings),' '),'RD-CNWDI')>0))
                then true() 
                else matches(./@ism:classification,'^(TS|S)$')
            " 
            flag="error">
            [ISM-ID-00175][Error] If ISM_CAPCO_RESOURCE and attribute 
            atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
            classification must have a value of [TS] or [S].
        </sch:assert>
    </sch:rule>
</sch:pattern>