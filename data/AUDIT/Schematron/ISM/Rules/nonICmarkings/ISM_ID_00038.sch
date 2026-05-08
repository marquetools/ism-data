<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00038" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens [XD] and [ND] are mutually 
        exclusive for attribute nonICmarkings.
        
        Human Readable: USA documents must not specify both XD and ND on a single element.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that the attribute
        nonICmarkings does not contain both a value of [XD] and a value of [ND].
    </sch:p>
    <sch:rule context="*[@ism:nonICmarkings]">
        <!-- get list of tokens in nonICmarkings attribute -->
        <sch:let name="nicmTok" value="tokenize(string(./@ism:nonICmarkings),' ')"/>
        
        <sch:assert 
            id="ISM-00038" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            not(index-of($nicmTok,'XD')>0 and index-of($nicmTok,'ND')>0)
            " 
            flag="error">
            [ISM-ID-00038][Error] If ISM_CAPCO_RESOURCE, then Name tokens [XD] and [ND] are mutually 
            exclusive for attribute nonICmarkings.
            
            Human Readable: USA documents must not specify both XD and ND on a single element.
        </sch:assert>
    </sch:rule>
</sch:pattern>