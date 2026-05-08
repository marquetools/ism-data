<?xml version="1.0" encoding="utf-8"?>
<sch:pattern id="ISM-ID-00165" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00165][Error] If ISM_CAPCO_RESOURCE and any element meeting ISM_CONTRIBUTES in the
        document have the attribute disseminationControls containing [RS] then the 
        ISM_RESOURCE_ELEMENT must have disseminationControls containing [RS].
        
        Human Readable: USA documents having RISK SENSITIVE (RS) data must have RS at the resource level.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If any element has attribute disseminationControls
        specified with a value containing [RS], then we make sure that the
        resourceElement has attribute disseminationControls specified with a value
        containing [RS].
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]">
        <sch:assert 
            id="ISM-00165" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
                if(index-of($partDisseminationControls_tok, 'RS')>0)
                    then index-of($bannerDisseminationControls_tok, 'RS') > 0
                    else true()
            " 
            flag="error">
            [ISM-ID-00165][Error] USA documents having RS Data must have RS at the resource level.
            
            Human Readable: USA documents having RISK SENSITIVE (RS) data must have RS at the resource level.
        </sch:assert>
    </sch:rule>
</sch:pattern>