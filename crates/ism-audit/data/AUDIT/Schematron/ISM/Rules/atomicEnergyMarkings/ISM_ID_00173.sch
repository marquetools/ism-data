<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00173" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with 
        [RD-SG] or [FRD-SG], then attribute classification must 
        have a value of [TS], [S], or [C].
        
        Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
        data should be CONFIDENTIAL, SECRET, or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Then we check that the attribute 
		atomicEnergyMarkings has a value of [RD-SG] or [FRD-SG] with a single digit 
		[1-9] or double digit [10-99]. If this element does contain one of those values 
		and its classification is not equal to TS, S or C, then the token is returned. If
		any token is returned, the count will be greater than 0 and the rule will fail.
    </sch:p>
    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        <sch:assert 
            id="ISM-00173" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else                  
            count(
                for $token in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return     
                    if(matches($token,'^F?RD-SG') 
                    and not( matches(./@ism:classification,'^(TS|S|C)$'))) 
                        then $token                
                        else null
            )=0
            " 
            flag="error">
            [ISM-ID-00173][Error] If ISM_CAPCO_RESOURCE and attribute 
            atomicEnergyMarkings contains a name token starting with [RD-SG] or [FRD-SG], then attribute 
            classification must have a value of [TS], [S], or [C].
            
            Human Readable: Portions in a USA document that contain RD or FRD SIGMA 
            data should be CONFIDENTIAL, SECRET, or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>