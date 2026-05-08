<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00213" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], then attribute displayOnlyTo 
        must be specified.
        
        Human Readable: A USA document with DISPLAY ONLY dissemination must indicate the countries
        to which it can be disseminated.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [DISPLAYONLY] then the attribute displayOnlyTo is specified and does not
        have an empty value set.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert             
            id="ISM-00031" 
            test="
            if(index-of(tokenize(string(./@ism:disseminationControls),' '),'DISPLAYONLY')>0)
            then ./@ism:displayOnlyTo and not(./@ism:displayOnlyTo = '')
            else true()
            " 
            flag="error">
            [ISM-ID-00213][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [DISPLAYONLY], then attribute displayOnlyTo 
            must be specified.
            
            Human Readable: A USA document with DISPLAY ONLY dissemination must indicate the countries
            to which it can be disseminated.
        </sch:assert>
    </sch:rule>
</sch:pattern>