<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00159" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00159][Error] If ISM_CAPCO_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contains [DoD-Dist-A].
        
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
    </sch:p>
    <sch:p id="codeDesc">
        If CAPCO rules do not apply to the document then the rule does not apply
        and we return true. If the document is Unclassified then the rule does not apply
        and we return true. Otherwise, we check that the current element does not have attribute 
        notice specified with a value containing [DoD-Dist-A].
    </sch:p>
    <sch:rule context="*[@ism:noticeType]">
        <!-- tokenize the notice attribute -->
        <sch:let name="noticeTok" value="tokenize(string(./@ism:noticeType), ' ')"/>
        
        <sch:assert id="ISM-00159"
            test="
            if(not($ISM_CAPCO_RESOURCE)) then true() else 
            if($bannerClassification='U') then true() else
            not(index-of($noticeTok, 'DoD-Dist-A')>0)
            "
            flag="error"> 
            [ISM-ID-00159][Error] Distribution statement A (Public Release) is forbidden on classified documents.
        </sch:assert>
    </sch:rule>
</sch:pattern>
