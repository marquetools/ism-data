<?xml version="1.0" encoding="utf-8"?>
<sch:pattern id="ISM-ID-00227" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
        resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
        
        Human Readable: Documents may only specify a document-level notice if
        it pertains to DoD Distribution.
    </sch:p>
    <sch:p id="codeDesc">
        For every resource element with the @ism:noticeType attribute specified,
        this rule ensures that the attribute's value starts with the string 
        'DoD-Dist-'. Otherwise, the rule returns false.
    </sch:p> 
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) 
		and @ism:noticeType]">       
        <sch:assert 
            id="ISM-00227" 
            test="
            starts-with(normalize-space(string(@ism:noticeType)), 'DoD-Dist-')
            " 
            flag="error">
            [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
            resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
            [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
            
            Human Readable: Documents may only specify a document-level notice if
            it pertains to DoD Distribution.
        </sch:assert>
    </sch:rule>
</sch:pattern>