<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00058" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00058][Error] If ISM_CAPCO_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [C] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [S] or [TS].
        
        Human Readable: USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply and we return 
        true. If the resourceElement has attribute classification specified with a value of 
        [C], then we make sure that no portion with ownerProducer containing USA has attribute 
        classification specified with a value of [TS] or [S]. 
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00058" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not(./@ism:classification='C')) then true() else 
            count(
                for $each in $partTags return
                    if(contains(string($each/@ism:ownerProducer), 'USA') and 
                       not($each/@ism:classification='U' or $each/@ism:classification='C') )
                        then $each
                        else null
            )=0
            " 
            flag="error">
            [ISM-ID-00058][Error] USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
        </sch:assert>
    </sch:rule>
</sch:pattern>