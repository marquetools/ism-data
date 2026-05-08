<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00017" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        classifiedBy is specified, then attribute classificationReason must be specified. 
        
        Human Readable: Documents under E.O. 13526 containing Originally Classified data 
        require a classification reason be identified.
    </sch:p>
    <sch:p id="codeDesc">
        If current Classified National Security Information Executive Order does not
        apply to this resource then the rule does not apply and we return true. 
        Otherwise we ensure that any element with the attribute classifiedBy also
        has the attribute classificationReason. 
    </sch:p>
    <sch:rule context="*[@ism:classifiedBy and $ISM_NSI_EO_APPLIES]">
        <sch:assert 
            id="ISM-00017" 
            test="./@ism:classificationReason" 
            flag="error">
            [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
            classifiedBy is specified, then attribute classificationReason must be specified. 
            
            Human Readable: Documents under E.O. 13526 containing Originally Classified data 
            require a classification reason be identified.
        </sch:assert>
    </sch:rule>
</sch:pattern>