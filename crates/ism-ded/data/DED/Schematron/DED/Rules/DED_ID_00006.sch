<?xml version="1.0" encoding="UTF-8"?><?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       --><sch:pattern xmlns:ism="urn:us:gov:ic:ism" 
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    id="DED-ID-00006">
    <sch:p class="ruleText"
        ism:classification="U" 
        ism:ownerProducer="USA" >
        [DED-ID-00006][Error] If ded:ElementObligation has the value of ‘Conditional” then ded:ElementRestrictions must exist.
    </sch:p>
    <sch:p class="codeDesc"
        ism:classification="U" 
        ism:ownerProducer="USA" >
        For ded:DataElements with ded:ElementObligation with the value of ‘Conditional”, ded:ElementRestrictions must exist.
    </sch:p>
    <sch:rule id="DED-ID-00006-R1" context="ded:DataElement[ded:ElementObligation/text()='Conditional']">
        <sch:assert test="ded:ElementRestrictions" flag="error" role="error">
            [DED-ID-00006][Error] If ded:ElementObligation has the value of ‘Conditional” then ded:ElementRestrictions must exist.
        </sch:assert>
    </sch:rule>
</sch:pattern>