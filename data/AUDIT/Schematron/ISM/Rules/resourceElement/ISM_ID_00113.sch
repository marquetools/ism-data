<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00113" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00113][Error] If ISM_CAPCO_RESOURCE and attribute SCIcontrols of ISM_RESOURCE_ELEMENT contains 
        [TK] and attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        SCIcontrols attribute containing [TK].
        
        Human Readable: USA TK documents not using compilation must have TK data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute SCIcontrols specified 
        with a value containing [TK] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute SCIcontrols specified with a value containing [TK].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00113" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if (index-of($bannerSCIcontrols_tok, 'TK')>0 and not(string-length(normalize-space(string(./@ism:compilationReason)))>0)) then
            index-of($partSCIcontrols_tok,'TK')>0
            else true()
            " 
            flag="error">
            [ISM-ID-00113][Error] USA TK documents not using compilation must have TK data.
        </sch:assert>
    </sch:rule>
</sch:pattern>