<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00108" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00108][Error] If ISM_CAPCO_RESOURCE and attribute classification 
        of ISM_RESOURCE_ELEMENT has a value of [TS] and attribute compilationReason does not have a value then at least 
        one element meeting ISM_CONTRIBUTES in the document must have a classification attribute of [TS]. 
        
        Human Readable: USA TS documents not using compilation must have TS data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. Then make sure we are looking at the resourceElement and 
        if the resourceElement has attribute classification specified 
        with a value of [TS] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute classification specified with a value of [TS].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00108" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if ($bannerClassification='TS' and not(string-length(normalize-space(string(./@ism:compilationReason)))>0)) then
                    index-of($partClassification_tok,'TS')>0
                    else true()
            " 
            flag="error">
            [ISM-ID-00108][Error] USA TS documents not using compilation must have TS data.
        </sch:assert>
    </sch:rule>
</sch:pattern>
