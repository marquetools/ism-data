<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00034" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00034][Error] If ISM_CAPCO_RESOURCE, then 
        tokens "RELIDO" and "NF" are mutually exclusive for attribute disseminationControls.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls that does not have
        values [RELIDO] and [NF] at the same time. 
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls),' ')"/>
        <sch:assert 
            id="ISM-00034" 
            test="not(index-of($dissemTok,'RELIDO')>0 and index-of($dissemTok,'NF')>0)" 
            flag="error">
            [ISM-ID-00034][Error] If ISM_CAPCO_RESOURCE, then 
            tokens "RELIDO" and "NF" are mutually exclusive for attribute disseminationControls.
        </sch:assert>
    </sch:rule>
</sch:pattern>