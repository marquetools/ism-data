<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00156" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00156][Error] If ISM-CAPCO-RESOURCE and:
        1. The attribute notice contains on of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E],
        [DoD-Dist-F], or [DoD-Dist-X]
        AND
        2. Attribute noticeDate is not specified
        AND
        3. Attribute pocType is not specified on some element in the document with the same 
           value as that of notice 
        
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all require a Date and a POC.
    </sch:p>
    <sch:p id="codeDesc">
        For every element that has a @noticeType attribute in a CAPCO document, if the 
        value of @noticeType is specified with a value containing [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X], 
        then we make sure that attribute @noticeDate is specified on the current element, and 
        somewhere in the document, the @pocType attribute is specified with the given value 
        of @noticeType.
    </sch:p>
    <sch:rule context="*[@ism:noticeType and $ISM_CAPCO_RESOURCE]">
        <!-- tokenize the element's notice attribute -->
        <sch:let name="noticeTok" value="normalize-space(string(./@ism:noticeType))"/>
        
        <sch:assert id="ISM-00156"
            test="
            if(index-of($noticeTok, 'DoD-Dist-B')>0 or
            index-of($noticeTok, 'DoD-Dist-C')>0 or
            index-of($noticeTok, 'DoD-Dist-D')>0 or
            index-of($noticeTok, 'DoD-Dist-E')>0 or
            index-of($noticeTok, 'DoD-Dist-F')>0 or
            index-of($noticeTok, 'DoD-Dist-X')>0) 
            then (./@ism:noticeDate and index-of($partPocType_tok,$noticeTok)>0)
            else true()
            "
            flag="error"> 
            [ISM-ID-00156][Error] DoD distribution statements B, C, D ,E ,F, and X all require a Date and a POC.
        </sch:assert>
    </sch:rule>
</sch:pattern>