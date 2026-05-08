<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" 
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    id="DED-ID-00007">
    <sch:p class="ruleText" 
        ism:classification="U" 
        ism:ownerProducer="USA" >
        [DED-ID-00007][Warning] For every optional element that exists in the 
        document and can have text content, the element should have non-null, 
        non-whitespace value.
    </sch:p>
    
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        This pattern uses an abstract rule to consolidate logic. The abstract rule
        first concatenates the text values within the given element, separated by a single 
        space. The resultant string is then normalized with leading and trailing 
        whitespace removed, and the length of the string is determined to be greater 
        than zero, which indicates non-whitespace content. The abstract rule is extended 
        once for each optional element in the DED schema.  
    </sch:p>
    
    <sch:rule abstract="true" id="abs.rule00001">
        <sch:assert test="normalize-space(string())" flag="warning" role="warning">
            [DED-ID-00007][Warning] For every optional element that exists in the 
            document and can have text content, the element should have non-null, 
            non-whitespace value.
        </sch:assert>
    </sch:rule>
    
    <!-- Begin using abstract rule on optional elements -->

    <sch:rule id="DED-ID-00007-R1" context="ded:ElementRestriction">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
</sch:pattern>