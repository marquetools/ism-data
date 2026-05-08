<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="IC-Docbook-ID-00001">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [IC-Docbook-ID-00001][Error] The version of IC-Docbook must be '5.0-variant urn:us:gov:ic:docbook-201804' for these rules to apply.
    </sch:p>
    
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        For each docbook element with attribute @version specified, this rule ensures that the value
        matches the version of this rule set.
    </sch:p>
    
    <sch:rule context="d:*[@version]" id="IC-Docbook-ID-00001-R1">
        <sch:assert test="matches(@version, '^5.0-variant urn:us:gov:ic:docbook-201804')" flag="error" role="error">
            [IC-Docbook-ID-00001][Error] The version of IC-Docbook must be '5.0-variant urn:us:gov:ic:docbook-201804' for these rules to apply.
        </sch:assert>
    </sch:rule>
</sch:pattern>
