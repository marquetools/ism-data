<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:domex="urn:us:mil:ces:metadata:domex"
    xmlns:Identity="urn:us:mil:ces:metadata:domex_identity" xmlns:cr="urn:CellexReport"
    xmlns:ism="urn:us:gov:ic:ism" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    id="DOMEX-ID-00012">
    <sch:p class="ruleText" ism:ownerProducer="USA" ism:classification="U">
        [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as version 202111
        (Version:2021-NOV) with an optional extension. 
    </sch:p>
    <sch:p class="codeDesc"> This rule checks the root element of a DOMEX assertion to ensure it has
        the appropriate DESVersion and supports extending the version identifier with an optional
        trailing hyphen and up to 23 additional characters. The version must match the regular
        expression “^202111(-.{1,23})?$".
    </sch:p>
    <sch:rule id="DOMEX-ID-00012-R1"
        context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex']">
        <sch:assert test="matches(@domex:DESVersion, '^202111(\-.{1,23})?$')" flag="warning"
            role="warning"> [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as
            version 202111 (Version:2021-NOV) with an optional extension. The value provided was:
            <sch:value-of select="@domex:DESVersion"/>
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00012-R2"
        context="tdf:StructuredStatement/*[namespace-uri() = 'urn:CellexReport']">
        <sch:assert test="matches(@cr:DESVersion, '^202111(\-.{1,23})?$')" flag="Warning"
            role="Warning"> [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as
            version 202111 (Version:2021-NOV) with an optional extension. The value provided was:
            <sch:value-of select="@cr:DESVersion"/>
        </sch:assert>
    </sch:rule>
    <sch:rule id="DOMEX-ID-00012-R3"
        context="tdf:StructuredStatement/*[namespace-uri() = 'urn:us:mil:ces:metadata:domex_identity']">
        <sch:assert test="matches(@Identity:DESVersion, '^202111(\-.{1,23})?$')" flag="Warning"
            role="Warning"> [DOMEX_ID_00012][Warning] DESVersion attribute SHOULD be specified as
            version 202111 (Version:2021-NOV) with an optional extension. The value provided was:
            <sch:value-of select="@Identity:DESVersion"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>
