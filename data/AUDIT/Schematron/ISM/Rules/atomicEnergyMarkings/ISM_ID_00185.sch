<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00185" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00185][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [RD-CNWDI],
        then it must also contain the name token [RD].
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value of [RD-CNWDI] then we also have
        a value of [RD].
    </sch:p>
    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        <sch:let name="atc_tok" value="tokenize(string(./@ism:atomicEnergyMarkings),' ')"/>
        <sch:assert 
            id="ISM-00185" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($atc_tok, 'RD-CNWDI')>0)
                then index-of($atc_tok, 'RD')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00185][Error] If ISM_CAPCO_RESOURCE and attribute atomicEnergyMarkings contains the name token [RD-CNWDI],
            then it must also contain the name token [RD].
        </sch:assert>
    </sch:rule>
</sch:pattern>