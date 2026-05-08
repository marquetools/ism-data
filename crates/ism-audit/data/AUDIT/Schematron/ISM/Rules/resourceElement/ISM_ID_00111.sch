<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00111" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00111][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [SI] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        SCIcontrols attribute containing [SI].
        
        Human Readable: USA SI documents not using compilation must have SI data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [SI] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [SI].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00111" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
                if (index-of($bannerSCIcontrols_tok, 'SI')>0 and not(string-length(normalize-space(string(./@ism:compilationReason)))>0)) then
                index-of($partSCIcontrols_tok,'SI')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00111][Error] USA SI documents not using compilation must have SI data.
        </sch:assert>
    </sch:rule>
</sch:pattern>