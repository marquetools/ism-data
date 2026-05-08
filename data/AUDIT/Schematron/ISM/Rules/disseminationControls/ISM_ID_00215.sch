<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00215" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00215][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with DISPLAYONLY dissemination must be classified
        CLASSIFIED, SECRET, or TOP SECRET.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [DISPLAYONLY] then we also have the attribute classification specified 
        with a value of [C], [S], or [TS] on the same element.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00215" 
            test="
            if(index-of(tokenize(string(./@ism:disseminationControls), ' '),'DISPLAYONLY')>0)
                then matches(./@ism:classification,'^(TS|S|C)$')
                else true()" 
        flag="error">
            [ISM-ID-00215][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [DISPLAYONLY], 
            then attribute classification must have a value of [TS], [S], or [C].    
            
            Human Readable: USA documents with DISPLAYONLY dissemination must be classified
            CLASSIFIED, SECRET, or TOP SECRET.
        </sch:assert>
    </sch:rule>
</sch:pattern>