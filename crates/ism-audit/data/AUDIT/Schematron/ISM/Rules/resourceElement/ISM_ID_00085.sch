<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00085" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00085][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        has the attribute nonICmarkings containing [XD] and does not have any element meeting ISM_CONTRIBUTES in the document having the 
        attribute nonICmarkings containing [ND] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [XD].
        
        Human Readable: USA documents having XD Data and not having ND must have XD at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute nonICmarkings specified
        with a value containing [XD] and no element has attribute nonICmarkings
        specified with a value containing [ND] and does not have attribute excludeFromRollup 
        set to true, then we make sure that the resourceElement 
        has attribute nonICmarkings specified with a value containing [XD].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00085" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            if(index-of($partNonICmarkings_tok, 'XD') > 0 and not(index-of($partNonICmarkings_tok, 'ND')>0))
            then index-of($bannerNonICmarkings_tok, 'XD') > 0
            else true()
            " 
            flag="error">
            [ISM-ID-00085][Error] USA documents having XD Data and not having ND must have XD at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>