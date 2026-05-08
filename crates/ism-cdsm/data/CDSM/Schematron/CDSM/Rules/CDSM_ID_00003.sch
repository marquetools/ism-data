<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="CDSM-ID-00003">
    <sch:p class="ruleText" ism:ownerProducer="USA" ism:classification="U">
        [CDSM-ID-00003][Error] If anlys:KnownMalicious exists, the value must be false or 0.
    </sch:p>
    <sch:p class="codeDesc" ism:ownerProducer="USA" ism:classification="U">
    </sch:p>
    <sch:rule id="CDSM-ID-00003-R1" context="anlys:KnownMalicious">
        <sch:assert test=".=false()" flag="error" role="error">
            [CDSM-ID-00003][Error] If anlys:KnownMalicious exists, the value must be false or 0.
        </sch:assert>
    </sch:rule>
</sch:pattern>