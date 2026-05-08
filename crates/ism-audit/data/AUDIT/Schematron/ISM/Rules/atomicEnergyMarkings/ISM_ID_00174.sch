<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00174" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00174][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD] or [FRD], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with RD or FRD data must be marked CLASSIFIED,
        SECRET, or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value of 
        [RD] or [FRD]  then we also have the attribute classification 
        specified with a value of [C], [S], or [TS] on the same element.
    </sch:p>
    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        <sch:assert 
            id="ISM-00174" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else                  
            count(
                for $token in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return     
                    if(matches($token,'^(F?RD)$') 
                       and not( matches(./@ism:classification,'^(TS|S|C)$'))) 
                        then $token                
                        else null
            )=0
            " 
            flag="error">
            [ISM-ID-00174][Error] If ISM_CAPCO_RESOURCE and attribute 
            atomicEnergyMarkings contains the name token [RD] or [FRD], 
            then attribute classification must have a value of [TS], [S], or [C].
            
            Human Readable: USA documents with RD or FRD data must be marked CLASSIFIED,
            SECRET, or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>