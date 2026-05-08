<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00154" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00154][Error] If ISM_CAPCO_RESOURCE and 
        1. Attribute disseminationControls of ISM_RESOURCE_ELEMENT contains [FOUO]
        AND
        2. Attribute compilationReason does not have a value then at least one element meeting ISM_CONTRIBUTES
           in the document must have a disseminationControls attribute contain [FOUO].
        
        Human Readable: USA FOUO documents not using compilation must have FOUO data.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute disseminationControls specified 
        with a value containing [FOUO] and the resourceElement has attribute compilationReason specified 
        with an empty value, then we make sure that at least one element in the document has 
        attribute disseminationControls specified with a value containing [FOUO].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00154" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
                if (index-of($bannerDisseminationControls_tok, 'FOUO')>0 and not(string-length(normalize-space(string(./@ism:compilationReason)))>0)) then
                index-of($partDisseminationControls_tok,'FOUO')>0
                else true()
            " 
            flag="error">
            [ISM-ID-00154][Error] USA FOUO documents not using compilation must have FOUO data.
        </sch:assert>
    </sch:rule>
</sch:pattern>