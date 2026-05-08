<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00186" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G-XXXX],
        then it must also contain the name token [SI-G].
        
        Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
        also specify that it contains SI-GAMMA compartment data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute SCIcontrols specified
        with a value containing [SI-G-XXXX], where X is represented by the regular expression character
        class [A-Z], then we make sure that attribute SCIcontrols also contains the value [SI-G].
    </sch:p>
    <sch:rule context="*[@ism:SCIcontrols]">
        <sch:assert 
            id="ISM-00186" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(
               count(
                   for $each in tokenize(string(./@ism:SCIcontrols),' ') return
                       if(matches($each,'^SI-G-[A-Z][A-Z][A-Z][A-Z]')) then 1 else null
               )>0
            )
                then index-of(tokenize(string(./@ism:SCIcontrols),' '), 'SI-G')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00186][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols contains the name token [SI-G-XXXX],
            then it must also contain the name token [SI-G].
            
            Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
            also specify that it contains SI-GAMMA compartment data.
        </sch:assert>
    </sch:rule>
</sch:pattern>