<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00037" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings contains 
        the name token [SINFO], [SBU], or [SBU-NF], then attribute classification must 
        have a value of [U].
        
        Human Readable: SINFO, SBU, and SBU-NF data must be marked UNCLASSIFIED in USA documents.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check if the attribute
        nonICmarkings contains a value of [SINFO], [SBU], or [SBU-NF] then the
        classification attribute must have a value of [U].
    </sch:p>
    <sch:rule context="*[@ism:nonICmarkings]">
        <sch:let name="nonICtok" value="tokenize(string(./@ism:nonICmarkings),' ')"/>
        <sch:assert 
            id="ISM-00037" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($nonICtok, 'SINFO')>0
              or index-of($nonICtok, 'SBU')>0
              or index-of($nonICtok, 'SBU-NF')>0)
                then ./@ism:classification='U'
                else true()
            " 
            flag="error">
            [ISM-ID-00037][Error] If ISM_CAPCO_RESOURCE and attribute nonICmarkings contains 
            the name token [SINFO], [SBU], or [SBU-NF], then attribute classification must have a value of [U].   
            
            Human Readable: SINFO, SBU, and SBU-NF data must be marked UNCLASSIFIED in USA documents.
        </sch:assert>
    </sch:rule>
</sch:pattern>