<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00132" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00132][Error] If ISM_CAPCO_RESOURCE and the ISM_RESOURCE_ELEMENT has the 
        attribute disseminationControls containing [RELIDO] then every element meeting 
        ISM_CONTRIBUTES_CLASSIFIED in the document must have the attribute 
        disseminationControls containing [RELIDO].
        
        Human Readable: USA documents having RELIDO at the resource level must have every classified portion having RELIDO.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the resourceElement has attribute disseminationControls specified 
        with a value containing [RELIDO], then we make sure that the number of elements in the document
        that have attribute classification specified with a value other than [U] and attribute 
        disseminationControls specified with a value containing [RELIDO] is the same as the number 
        of elements in the document that have attribute classification specified with a value other than [U].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00132" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
                if(index-of($bannerDisseminationControls_tok, 'RELIDO')>0)
                then sum(for $token in $partTags return
                            if(not($token/@ism:classification='U') and index-of(tokenize(string($token/@ism:disseminationControls),' '), 'RELIDO')>0)
                            then 1 else 0
                     ) = count(for $tag in $partTags return if($tag/@ism:classification='U') then null else 1)
                else true()
            " 
            flag="error">
            [ISM-ID-00132][Error] USA documents having RELIDO at the resource level must have every classified portion having RELIDO.
        </sch:assert>
    </sch:rule>
</sch:pattern>