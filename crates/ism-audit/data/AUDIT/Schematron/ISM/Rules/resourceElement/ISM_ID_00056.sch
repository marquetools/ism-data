<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00056" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00056][Error] If ISM_CAPCO_RESOURCE and attribute classification of 
        ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES_USA in the document may have 
        a classification attribute of [C], [S] or [TS].
        
        Human Readable: USA UNCLASSIFIED documents can’t have TOP SECRET, SECRET, or CONFIDENTIAL data.    
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute classification
        specified with a value of [U], then we make sure that no portion with ownerProducer containing
        USA has attribute classification specified with a value of [C], [S], or [TS].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00056" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(not(./@ism:classification='U')) then true() else 
            count(
                for $each in $partTags return
                    if(contains(string($each/@ism:ownerProducer), 'USA') and 
                       not($each/@ism:classification='U'))
                          then $each
                          else null
            )=0
            "
            flag="error">
            [ISM-ID-00056][Error] USA UNCLASSIFIED documents can't have TOP SECRET, SECRET, or CONFIDENTIAL data.    
        </sch:assert>
    </sch:rule>
</sch:pattern>