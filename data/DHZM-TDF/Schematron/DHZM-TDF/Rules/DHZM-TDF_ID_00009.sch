<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DHZM-TDF-ID-00009">
    <sch:p class="ruleText" ism:ownerProducer="USA" ism:classification="U"> 
        [DHZM-TDF-ID-00009][Error] In a DHZM-TDF TDO, there must be a dhzm:DigitalHazMatAssertion and only 1 of them.
    </sch:p>
    <sch:p class="codeDesc" ism:ownerProducer="USA" ism:classification="U">
        In a DHZM-TDF tdf:TrustedDataObject, there must be a dhzm:DigitalHazMatAssertion and only 1 of them.
    </sch:p>
    <sch:rule id="DHZM-TDF-ID-00009-R1" context="tdf:TrustedDataObject">
        <sch:assert test=".//dhzm:DigitalHazMatAssertion and count(.//dhzm:DigitalHazMatAssertion) = 1" flag="error" role="error"> 
            [DHZM-TDF-ID-00009][Error] In a DHZM-TDF TDO, there must be a dhzm:DigitalHazMatAssertion and only 1 of them.
        </sch:assert>
    </sch:rule>
</sch:pattern>