<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00226" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    
    <sch:p id="ruleText">
        [ISM-ID-00226][Error] @ism:noticeType and @ism:unregisteredNoticeType
        may not both be used on the same element. 
        
        Human Readable: Ensure that the ISM attributes noticeType and
        unregisteredNoticeType are not used on the same element.
    </sch:p>
    <sch:p id="codeDesc">
        Any element that has either @ism:noticeType or @ism:unregisteredNoticeType. 
    </sch:p>

    <sch:rule context="*[@ism:noticeType|@ism:unregisteredNoticeType]">        
        <!-- Execute tests --> 
        <sch:assert id="ISM-00226" flag="error"
            test="count(@ism:noticeType|@ism:unregisteredNoticeType)=1">
            [ISM-ID-00226][Error]
            @ism:noticeType and @ism:unregisteredNoticeType may not both be applied to the same element.
            
            Human Readable: The ISM attributes noticeType and unregisteredNoticeType 
            are mutually exclusive and cannot both be applied to the same element. 
        </sch:assert>
    </sch:rule>
</sch:pattern>