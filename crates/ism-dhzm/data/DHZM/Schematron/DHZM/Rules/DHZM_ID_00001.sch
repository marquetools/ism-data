<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DHZM-ID-00001">
    <sch:p class="ruleText" ism:ownerProducer="USA" ism:classification="U">
        [DHZM-ID-00001][Warning] dhzm:DESVersion attribute SHOULD be specified as revision 202111 (Version:2021-NOV) 
        with an optional extension.
    </sch:p>
    <sch:p class="codeDesc" ism:ownerProducer="USA" ism:classification="U">
        This rule supports extending the version identifier with an optional trailing hyphen
        and up to 23 additional characters. The version must match the regular expression
        “^202111(-.{1,23})?$".
    </sch:p>
    <sch:rule id="DHZM-ID-00001-R1" context="*[@dhzm:DESVersion]">
        <sch:assert test="matches(@dhzm:DESVersion,'^202111(\-.{1,23})?$')" flag="warning" role="warning">
            [DHZM-ID-00001][Warning] dhzm:DESVersion attribute SHOULD be specified as version 202111 (Version:2021-NOV) 
            with an optional extension. The value provided was: <sch:value-of select="./@dhzm:DESVersion"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>