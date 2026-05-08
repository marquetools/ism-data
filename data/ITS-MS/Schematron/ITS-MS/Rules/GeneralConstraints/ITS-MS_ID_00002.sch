<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="ITS-MS-ID-00002">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [ITS-MS-ID-00002][Warning] DESVersion attributes SHOULD be specified as revision 201502.201807 with an optional extension.
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        This rule supports extending the version identifier with an optional trailing hyphen
        and up to 23 additional characters. The version must match the regular expression
        “^201502.201807(-.{1,23})?$".
    </sch:p>
    <sch:rule id="ITS-MS-ID-00002-R1" context="*[@DESVersion]">
        <sch:assert test="matches(@DESVersion,'^201502.201807(-.{1,23})?$')" flag="warning" role="warning">
            [ITS-MS-ID-00002][Warning] DESVersion attributes found was "<sch:value-of select="@DESVersion"/>" it SHOULD be 
            specified as revision 201502.201807 with an optional extension.
        </sch:assert>
    </sch:rule>
</sch:pattern>