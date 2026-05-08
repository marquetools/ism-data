<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00169" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00169][Error] If ISM_CAPCO_RESOURCE, and attribute disseminationControls 
        contains name token [DISPLAYONLY] then tokens [RELIDO] and [NF] may not also be used.
        
        Human Readable: In a USA document, DISPLAY ONLY, RELIDO and NO FOREIGN dissemination are 
        mutually exclusive for a single element.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of [DISPLAYONLY] then
        it does not have a value of [RELIDO] or [NF] also.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls),' ')"/>
        <sch:assert 
            id="ISM-00169" 
            test="
            if(index-of($dissemTok,'DISPLAYONLY')>0)
                then not(index-of($dissemTok,'RELIDO')>0 
                        or index-of($dissemTok,'NF')>0)
                else true()
            " 
            flag="error">
            [ISM-ID-00169][Error] If ISM_CAPCO_RESOURCE, and attribute disseminationControls 
            contains name token [DISPLAYONLY] then tokens [RELIDO] and [NF] may not also be used.
            
            Human Readable: In a USA document, DISPLAY ONLY, RELIDO and NO FOREIGN dissemination are 
            mutually exclusive for a single element.
        </sch:assert>
    </sch:rule>
</sch:pattern>