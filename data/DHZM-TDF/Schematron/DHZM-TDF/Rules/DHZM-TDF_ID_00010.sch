<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DHZM-TDF-ID-00010">
    <sch:p class="ruleText" ism:ownerProducer="USA" ism:classification="U"> 
        [DHZM-TDF-ID-00010][Warning] In a DHZM-TDF TDO, dhzm:DigitalHazMatAssertion must be the first tdf:Assertion.
    </sch:p>
    <sch:p class="codeDesc" ism:ownerProducer="USA" ism:classification="U">
        In a DHZM-TDF tdf:TrustedDataObject, dhzm:DigitalHazMatAssertion must be the first tdf:Assertion.
    </sch:p>
    <sch:rule id="DHZM-TDF-ID-00010-R1" context="tdf:TrustedDataObject//tdf:Assertion[1]">
        <sch:assert test=".//dhzm:DigitalHazMatAssertion" flag="warning" role="warning"> 
            [DHZM-TDF-ID-00010][Warning] In a DHZM-TDF TDO, dhzm:DigitalHazMatAssertion must be the first tdf:Assertion.
        </sch:assert>
    </sch:rule>
</sch:pattern>