<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00176" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00176][Error] If ISM_CAPCO_RESOURCE and attribute 
        atomicEnergyMarkings has a name token containing [RD] or [FRD], 
        then attributes declassDate and declassEvent cannot be specified
        on the resourceElement.
        
        Human Readable: Automatic declassification of documents containing RD or FRD information is prohibited.
        Attributes declassDate and declassEvent cannot be used in the classification authority block when RD or FRD is present.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute atomicEnergyMarkings with a value containing [RD] or
        [FRD] then we make sure that the resourceElement does not have attributes
        declassDate or declassEvent specified.
    </sch:p>
    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        <sch:assert 
            id="ISM-00176" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            count(
                for $each in tokenize(string(./@ism:atomicEnergyMarkings),' ') return
                    if(matches($each, '^(F?RD)$'))
                        then if($ISM_RESOURCE_ELEMENT/@ism:declassDate
                                or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)
                                 then 1 
                                 else null
                        else null
            )=0
            " 
            flag="error">
            [ISM-ID-00176][Error] Automatic declassification of documents containing RD or FRD information is prohibited.
            Attributes declassDate and declassEvent cannot be used in the classification authority block when RD or FRD is present.
        </sch:assert>
    </sch:rule>
</sch:pattern>