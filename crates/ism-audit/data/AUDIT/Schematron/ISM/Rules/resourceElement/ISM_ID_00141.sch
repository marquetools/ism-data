<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00141" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00141][Error] If ISM_NSI_EO_APPLIES and 
        1. ISM_RESOURCE_ELEMENT attribute declassException does not have a value of [25X1-human], [50X1-HUM], or [50X2-WMD]
        AND
        2. ISM_RESOURCE_ELEMENT attribute declassDate is not specified
        AND
        3. ISM_RESOURCE_ELEMENT attribute declassEvent is not specified
        AND
        4. ISM_RESOURCE_ELEMENT attribute atomicEnergyMarkings is not specified
           with a value of [RD] or [FRD]
            
        Human Readable: Documents under E.O. 13526 require declassDate or declassEvent unless 
        25X1-human, 50X1-HUM, 50X2-WMD, RD, or FRD is specified.
    </sch:p>
    <sch:p id="codeDesc">
        If the current Classified National Security Information Executive Order
        does not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute declassException specified 
        with a value of [25X1-human], [50X1-HUM], or [50X2-WMD], then the rule does not apply and we return true. If 
        the resourceElement has attribute atomicEnergyMarkings specified with a value containing
        [RD] or [FRD] then the rule does not apply and we return true. Otherwise, we make sure
        that the resourceElement has attribute declassDate specified or attribute declassEvent 
        specified.
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:let name="paddedDeclassEx" 
            value="concat(' ', normalize-space(string(./@ism:declassException)), ' ')"/>
        
        <sch:assert 
            id="ISM-00141" 
            test="
            if(not($ISM_NSI_EO_APPLIES)) then true() else 
            if(matches($paddedDeclassEx, ' (25X1-human|50X1-HUM|50X2-WMD) ')) then true() else
                    if(
                        sum(
                            for $each in tokenize(string(./@ism:atomicEnergyMarkings), ' ') return
                                if(matches($each, '^F?RD-?.*$'))
                                    then 1
                                    else 0
                        )>0
                    ) then true()
                    else (./@ism:declassDate or ./@ism:declassEvent)
            " 
            flag="error">
            [ISM-ID-00141][Error] Documents under E.O. 13526 require declassDate or declassEvent unless 25X1-human, 
            50X1-HUM, 50X2-WMD, RD, or FRD is specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>