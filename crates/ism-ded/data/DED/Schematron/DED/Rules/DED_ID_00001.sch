<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DED-ID-00001">
    <sch:p class="ruleText">
        [DED-ID-00001][warning] The ded:DESVersion attribute SHOULD be specified as version 201903 (Version:2019-MAR) with an optional extension.
    </sch:p>
    
    <sch:p class="codeDesc">
        For each element with attribute DED:DESVersion specified, this rule ensures that the value
        matches the version of this rule set.
    </sch:p>
    
    <sch:rule context="*[@ded:DESVersion]" id="DED-ID-00001-R1">
        <sch:assert test="matches(@ded:DESVersion, '^201903(\-.{1,23})?$')" flag="warning" role="warning">
            [DED-ID-00001][warning] The ded:DESVersion attribute SHOULD be specified as version 201903 (Version:2019-MAR) with an optional extension. The value provided was: <sch:value-of select="@ded:DESVersion"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>
