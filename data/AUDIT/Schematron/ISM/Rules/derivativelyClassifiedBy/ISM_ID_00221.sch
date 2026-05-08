<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00221" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute classificationReason
        must not be specified.
        
        Human Readable: USA documents that are derivatively classified must not
        specify a classification reason.
    </sch:p>
    <sch:p id="codeDesc">
    	For each element with the attribute derivativelyClassifiedBy specified,
    	we make sure that the attribute classificationReason is not specified.
    </sch:p>
    <sch:rule context="*[@ism:derivativelyClassifiedBy and $ISM_CAPCO_RESOURCE]">
        <sch:assert 
        		id="ISM-00221" 
            test="not(@ism:classificationReason)" 
            flag="error">
        	[ISM-ID-00221][Error] If ISM_CAPCO_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute classificationReason
        	must not be specified.
        	
        	Human Readable: USA documents that are derivatively classified must not
        	specify a classification reason.
        </sch:assert>
    </sch:rule>
</sch:pattern>