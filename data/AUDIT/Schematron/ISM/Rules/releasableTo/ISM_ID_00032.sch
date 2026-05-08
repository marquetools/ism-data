<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00032" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
        disseminationControls is not specified, or is specified and does not contain the name token 
        [REL] or [EYES], then attribute releasableTo must not be specified.
        
        Human Readable: USA documents must only specify to which countries it is 
        authorized for release if dissemination information contains REL TO or EYES ONLY data. 
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the attribute releasableTo is specified, then we make sure
        that the attribute disseminationControls is specified with a value containing
        [EYES] or [REL].
    </sch:p>
    <sch:rule context="*[@ism:releasableTo and $ISM_CAPCO_RESOURCE]">
        
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls),' ')"/>
        <sch:assert 
            id="ISM-00032" 
            test="
            index-of($dissemTok,'EYES')>0 or index-of($dissemTok,'REL')>0
            "
            flag="error">
            [ISM-ID-00032][Error] If ISM_CAPCO_RESOURCE and attribute 
            disseminationControls is not specified, or is specified and does not contain the name token 
            [REL] or [EYES], then attribute releasableTo must not be specified.
            
            Human Readable: USA documents must only specify to which countries it is 
            authorized for release if dissemination information contains REL TO or EYES ONLY data. 
        </sch:assert>
    </sch:rule>
</sch:pattern>