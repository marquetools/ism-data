<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00112" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00112][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [SI-G] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have 
        a SCIcontrols attribute containing [SI-G].
        
        Human Readable: USA SI-G documents not using compilation must have SI-G data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [SI-G] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [SI-G].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00112" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if (contains(string($bannerSCIcontrols), 'SI-G') and not(string-length(normalize-space(string(./@ism:compilationReason)))>0)) then
            index-of($partSCIcontrols_tok,'SI-G')>0
            else true()
            " 
            flag="error">
            [ISM-ID-00112][Error] USA SI-G documents not using compilation must have SI-G data.
        </sch:assert>
    </sch:rule>
</sch:pattern>