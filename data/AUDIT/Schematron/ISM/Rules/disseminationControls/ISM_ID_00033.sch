<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00033" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then 
        tokens [REL], [EYES] and [NF] are mutually exclusive for attribute disseminationControls.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls and counting 1 for each
        value of [REL], [NF] or [EYES] found. If the count is greater than one then
        then the values are not being used exclusively with respect to each other.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls),' ')"/>
        <sch:assert 
            id="ISM-00033" 
            test="   
            not(
              count((
                    if(index-of($dissemTok,'REL')>0) then 1 else null,
                    if(index-of($dissemTok,'NF')>0) then 1 else null,
                    if(index-of($dissemTok, 'EYES')>0) then 1 else null)
              ) > 1
            )
            " 
            flag="error">
            [ISM-ID-00033][Error] If ISM_CAPCO_RESOURCE, then 
            tokens [REL], [EYES] and [NF] are mutually exclusive for attribute disseminationControls.
        </sch:assert>
    </sch:rule>
</sch:pattern>