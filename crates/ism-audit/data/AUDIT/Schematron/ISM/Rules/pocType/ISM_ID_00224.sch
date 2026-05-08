<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00224" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00224][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document has the attribute disseminationControls containing [OC], then the 
        attribute @ism:pocType with value [ORCON] must be specified on some element in the document. 
        
        Human Readable: In accordance with the ORCON Memo dated March 11, 2011, 
        USA documents containing ORIGINATOR CONTROLLED data must specify a 
        point-of-contact to whom adjudication decisions about those data can be directed.  
    </sch:p>
    <sch:p id="codeDesc">
        The rule will apply to the resource element of a CAPCO document that was created after
        the date after which ORCON points-of-contact became required. For this element, if 
        ORCON data is found, then the code checks if the attribute @ism:pocType is specified 
        with the value 'ORCON' on some element. Otherwise, the rule does not apply and 
        true is returned.
    </sch:p>
    <sch:rule context="*[generate-id(.)=generate-id($ISM_RESOURCE_ELEMENT)
        and $ISM_CAPCO_RESOURCE 
        and $ISM_RESOURCE_CREATE_DATE
        and $ISM_RESOURCE_CREATE_DATE &gt; $ISM_ORCON_POC_DATE
        and $bannerDisseminationControls_tok='OC'
        ]">
        <sch:assert 
            id="ISM-00224" 
            test="
                $partPocType_tok='ORCON'
            " 
            flag="error">
            [ISM-ID-00224][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES 
            in the document has the attribute disseminationControls containing [OC], then the 
            attribute @ism:pocType with value [ORCON] must be specified on some element in the document. 
            
            Human Readable: After March 11, 2011, USA documents containing ORIGINATOR CONTROLLED 
            data must specify a point-of-contact to whom adjudication decisions about 
            those data can be directed. 
        </sch:assert>
    </sch:rule>
</sch:pattern>