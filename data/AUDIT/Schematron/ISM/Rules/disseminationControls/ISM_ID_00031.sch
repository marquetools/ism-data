<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00031" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls contains the name token [REL] or [EYES], then attribute releasableTo 
        must be specified.
        
        Human Readable: USA documents containing REL TO or EYES ONLY dissemination must
        specify to which countries the document is releasable.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If it is a CAPCO resource then we check that if we have
        an element having attribute disseminationControls with a value of 
        [REL] or [EYES] then the attribute releasableTo is specified and does not
        have an empty value set.
    </sch:p>
    <sch:rule context="*[@ism:disseminationControls and $ISM_CAPCO_RESOURCE]">
        <sch:assert             
            id="ISM-00031" 
            test="
            if(matches(concat(' ',string-join(string(@ism:disseminationControls),' '),' '), ' (REL|EYES) '))
                then @ism:releasableTo
                else true()
            " 
            flag="error">
            [ISM-ID-00031][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls contains the name token [REL] or [EYES], then attribute releasableTo 
            must be specified.
            
            Human Readable: USA documents containing REL TO or EYES ONLY dissemination must
            specify to which countries the document is releasable.
        </sch:assert>
    </sch:rule>
</sch:pattern>