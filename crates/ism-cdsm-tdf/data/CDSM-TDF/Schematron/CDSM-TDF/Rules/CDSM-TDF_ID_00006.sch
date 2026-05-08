<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="CDSM-TDF-ID-00006">
    <sch:p class="ruleText" ism:ownerProducer="USA" ism:classification="U">
        [CDSM-TDF-ID-00006][Error] In a CDSM-TDF TDO, there must be only 1 cdsm:CdsManifestAssertion.
    </sch:p>
    <sch:p class="codeDesc" ism:ownerProducer="USA" ism:classification="U">
        In a CDSM-TDF tdf:TrustedDataObject, there must be only 1 cdsm:CdsManifestAssertion.
    </sch:p>
    <sch:rule id="CDSM-TDF-ID-00006-R1" context="tdf:TrustedDataObject">
        <sch:assert test=".//cdsm:CdsManifestAssertion and count(.//cdsm:CdsManifestAssertion) = 1" flag="error" role="error">
            [CDSM-TDF-ID-00006][Error] In a CDSM-TDF TDO, there must be only 1 cdsm:CdsManifestAssertion.
        </sch:assert>
    </sch:rule>
</sch:pattern>