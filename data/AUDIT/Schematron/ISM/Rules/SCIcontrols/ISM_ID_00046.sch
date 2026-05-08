<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00046" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00046][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains 
        a name token starting with [SI-ECI], then attribute classification must have a 
        value of [TS].
        
        Human Readable: A USA document containing Special Intelligence (SI) ECI compartment
        data must be classified TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute classification specified
        with a value of [TS] then the rule does not apply and we return true. 
        Otherwise, we make sure that attribute SCIcontrols does not contain the value [SI-ECI].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00046" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(matches(./@ism:classification,'^TS$')) then true() else
            count(
                for $token in tokenize(string(./@ism:SCIcontrols),' ') return     
                if(matches($token,'^SI-ECI')) then 1 else null
            )=0
            " 
            flag="error">
            [ISM-ID-00046][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains 
            a name token starting with [SI-ECI], then attribute classification must have a 
            value of [TS].
            
            Human Readable: A USA document containing Special Intelligence (SI) ECI compartment
            data must be classified TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>