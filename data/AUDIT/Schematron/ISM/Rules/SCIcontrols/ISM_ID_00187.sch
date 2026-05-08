<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00187" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
        then it must also contain the name token [SI].
        
        Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
        it contains SI data. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G], then we make sure that attribute SCIcontrols also contains the value [SI].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00187" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(
               count(
                   for $each in tokenize(string(./@ism:SCIcontrols),' ') return
                       if(matches($each,'^SI-G')) then 1 else null
               )>0
            )
                then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00187][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
            then it must also contain the name token [SI].
            
            Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
            it contains SI data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>