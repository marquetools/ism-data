<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00214" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
        releasableTo must start with [USA].
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the attribute releasableTo is specified, then we make sure
        that it starts with [USA].
    </sch:p>
    <sch:rule context="*[@ism:releasableTo]">
        
        <sch:let name="dissemTok" value="tokenize(string(./@ism:disseminationControls),' ')"/>
        <sch:assert 
            id="ISM-00032" 
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else
            index-of(tokenize(string(./@ism:releasableTo),' '),'USA')=1
            "
            flag="error">
            [ISM-ID-00214][Error] If ISM_CAPCO_RESOURCE then attribute 
            releasableTo must start with [USA].
        </sch:assert>
    </sch:rule>
</sch:pattern>