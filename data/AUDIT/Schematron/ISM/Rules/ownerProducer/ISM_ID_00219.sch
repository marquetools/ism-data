<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00219" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute ownerProducer contains [FGI], 
        then FGIsourceProtected must have a value of [FGI].
        
        Human Readable: Any non-resource element that contributes to the document's banner roll-up and has
        FOREIGN GOVERNMENT INFORMATION (FGI) must also specify attribute FGIsourceProtected with token FGI.
    </sch:p>
    <sch:p id="codeDesc">
        If not ISM_CONTRIBUTES then return true, otherwise, we make sure that if the current 
        element has attribute ownerProducer specified with [FGI] then FGIsourceProtected 
        also has a value of [FGI].
    </sch:p>
    <sch:rule context="*[@ism:ownerProducer and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)) and not(@ism:excludeFromRollup=true())]">
        <sch:assert 
            id="ISM-00219" 
            test="
            if(index-of(./@ism:ownerProducer,'FGI')>0)
            then index-of(./@ism:FGIsourceProtected,'FGI')>0
            else true()
            " 
            flag="error">
            [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute ownerProducer contains [FGI], 
            then FGIsourceProtected must have a value of [FGI].
            
            Human Readable: Any non-resource element that contributes to the document's banner roll-up and has
            FOREIGN GOVERNMENT INFORMATION (FGI) must also specify attribute FGIsourceProtected with token FGI.
        </sch:assert>
    </sch:rule>
</sch:pattern>