<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00097" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00097][Warning] If ISM_CAPCO_RESOURCE and attribute FGIsourceProtected is 
        specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        
        Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.    
    </sch:p>
    <sch:p id="codeDesc">
        Checks that the resource is a CAPCO resource and that the FGIsourceProtected 
        attribute contains only the value [FGI].
    </sch:p>
    <sch:rule context="*[@ism:FGIsourceProtected and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
            id="ISM-00097" 
            test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'
            " 
            flag="warning">
            [ISM-ID-00097][Warning] FGI Protected should rarely if ever be seen outside of an agency's internal systems.
        </sch:assert>
    </sch:rule>
</sch:pattern>