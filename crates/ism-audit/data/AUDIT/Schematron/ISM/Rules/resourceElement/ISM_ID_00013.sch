<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00013" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00013][Error] If ISM_NSI_EO_APPLIES then either attribute classifiedBy or 
        derivedFrom must be specified on the ISM_RESOURCE_ELEMENT. 
        
        Human Readable: Documents under E.O. 13526 must have classification authority block information.
    </sch:p>
    <sch:p id="codeDesc">
        If the current Classified National Security Information Executive Order
        does not apply to the document then the rule does not apply and we return true.
        Otherwise, we make sure that the resourceElement has attribute
        classifiedBy or derivedFrom specified.
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00013" 
            test="
            if(not($ISM_NSI_EO_APPLIES)) then true() 
            else if(./@ism:classifiedBy or ./@ism:derivedFrom) then true() 
            else false()
            " 
            flag="error">
            [ISM-ID-00013][Error] Documents under E.O. 13526 must have classification authority block information.
        </sch:assert>
    </sch:rule>
</sch:pattern>