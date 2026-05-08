<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00012" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00012][Error] If any of the attributes defined in 
        this DES other than DESVersion, unregisteredNoticeType, or pocType are specified for an element, 
        then attributes classification and ownerProducer must be specified for the element.
    </sch:p>
    <sch:p id="codeDesc">
        This code triggers on elements that have an ISM attribute whose name is not 'DESVersion' and
        it ensures that both the ownerProducer and classification attributes are present 
		on the element.
    </sch:p>
    <sch:rule context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType)]">
        <sch:assert 
            id="ISM-00012" 
            test="
              (./@ism:ownerProducer and ./@ism:classification)
            " 
            flag="error">
            [ISM-ID-00012][Error] If any of the attributes defined in 
            this DES other than DESVersion, unregisteredNoticeType, or pocType are specified for an element, 
            then attributes classification and ownerProducer must be specified for the element.
        </sch:assert>
    </sch:rule>
</sch:pattern>