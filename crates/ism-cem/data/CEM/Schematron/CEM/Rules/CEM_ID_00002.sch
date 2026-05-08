<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="CEM-ID-00002">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [CEM-ID-00002][Error]
        For elements Facility and Person, if attribute xlink:href exists, then the attribute must have a non-null value.
        
        Human Readable: If attribute xlink:href exists for elements Facility and Person, it must have a value.
    </sch:p>
    
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        This pattern uses an abstract rule to consolidate logic. It normalizes the
        space of the value of attribute xlink:href and makes sure the length of the
        resulting string is greater than zero, which indicates non-whitespace content.
        The abstract rule is extended once for each required element.
    </sch:p>
    
    <!-- Abstract rule, which asserts that if attribute xlink:href exists, then it must have a non-null value -->
    <sch:rule abstract="true" id="abs.rule00002">
        <sch:assert test="normalize-space(string(@xlink:href))" flag="error" role="error">
            [CEM-ID-00002][Error]
            For element <sch:name/> if attribute xlink:href exists, then the attribute must have a non-null value.
        </sch:assert>
    </sch:rule>
    
    <!-- Begin using abstract rule to check required elements -->
    <sch:rule context="cem:Facility[@xlink:href]" id="CEM-ID-00002-R1">
        <sch:extends rule="abs.rule00002"/>
    </sch:rule>
    
    <sch:rule context="cem:Person[@xlink:href]" id="CEM-ID-00002-R2">
        <sch:extends rule="abs.rule00002"/>
    </sch:rule>
    
</sch:pattern>
