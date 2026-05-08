<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00157" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00157][Error] If ISM_CAPCO_RESOURCE and:
        1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E]
        AND
        2. The attribute noticeReason is not specified.
        
        Human Readable: DoD distribution statements B, C, D , or E  all require a reason.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the current element has attribute notice specified 
        with a value containing [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], 
        or [DoD-Dist-F], then we make sure that attribute noticeReason is also specified 
        on the resourceElement.
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <!-- tokenize the notice attribute -->
        <sch:let name="noticeTok" value="tokenize(string(./@ism:noticeType), ' ')"/>
        
        <sch:assert id="ISM-00157"
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if(
                count(
                    (if(index-of($noticeTok, 'DoD-Dist-B')>0) then 1 else null,
                     if(index-of($noticeTok, 'DoD-Dist-C')>0) then 1 else null,
                     if(index-of($noticeTok, 'DoD-Dist-D')>0) then 1 else null,
                     if(index-of($noticeTok, 'DoD-Dist-E')>0) then 1 else null)
                )=0
            ) 
                then true() 
                else ./@ism:noticeReason
            "
            flag="error"> 
            [ISM-ID-00157][Error] DoD distribution statements B, C, D , or E  all require a reason.
        </sch:assert>
    </sch:rule>
</sch:pattern>
