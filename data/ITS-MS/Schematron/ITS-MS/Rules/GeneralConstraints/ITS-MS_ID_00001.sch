<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="ITS-MS-ID-00001" xmlns:ism="urn:us:gov:ic:ism">
    <sch:p ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [ITS-MS-ID-00001][Error] The @ism:DESVersion is less than the minimum version 
        allowed: 2014-DEC (201412).
        
        Human Readable: The ISM version imported by ITS-MS must be greater than or equal to 2014-DEC (201412).
    </sch:p>
    <sch:p ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        For all elements that contain @ism:DESVersion, this rule verifies that the version
        is greater than or equal to the minimum allowed version: 2014-DEC (201412).
    </sch:p>
    <sch:rule id="ITS-MS-ID-00001-R1" context="*[@ism:DESVersion]">
        <sch:let name="version" value="number(if (contains(@ism:DESVersion,'-')) then substring-before(@ism:DESVersion,'-') else @ism:DESVersion)"/>
        <sch:assert test="$version &gt;= 201412" flag="error" role="error">
            [ITS-MS-ID-00001][Error] The @ism:DESVersion <sch:value-of select="./@ism:DESVersion"/> is less than the minimum version 
            allowed: 2014-DEC (201412). 
            
            Human Readable: The ISM version imported by ITS-MS must be greater than or equal to 2014-DEC (201412). 
        </sch:assert>
    </sch:rule>
</sch:pattern>