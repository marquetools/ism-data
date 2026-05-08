<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00168" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified or is specified and does not contain the name token 
        [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
        
        Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
        it must not list countries to which it can be disseminated. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if the
        attribute displayOnlyTo is specified then the 
        attribute disseminationControls is also specified that it contains a value of 
        [DISPLAYONLY]
    </sch:p>
    <sch:rule context="*[@ism:displayOnlyTo and $ISM_CAPCO_RESOURCE]">
        
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls),' ')"/>
        <sch:assert 
            id="ISM-00168" 
            test="index-of($dissemTok,'DISPLAYONLY')>0"
            flag="error">
            [ISM-ID-00168][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified or is specified and does not contain the name token 
            [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
            
            Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
            it must not list countries to which it can be disseminated.
        </sch:assert>
    </sch:rule>
</sch:pattern>