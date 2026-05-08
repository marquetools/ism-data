<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="ITS-MS-ID-00003" xmlns:ism="urn:us:gov:ic:ism">
    <sch:p ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [ITS-MS-ID-00003][Error] The @tdf:version is less than the minimum version 
        allowed: 2014-DEC (201412).
        
        Human Readable: The IC-TDF version imported by ITS-MS must be greater than or equal to 2014-DEC (201412).
    </sch:p>
    <sch:p ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        For all elements that contain @tdf:version, this rule verifies that the version
        is greater than or equal to the minimum allowed version: 2014-DEC (201412).
    </sch:p>
    <sch:rule id="ITS-MS-ID-00003-R1" context="*[@tdf:version]">
        <sch:let name="version" value="number(if (contains(@tdf:version,'-')) then substring-before(@tdf:version,'-') else @tdf:version)"/>
        <sch:assert test="$version &gt;= 201412" flag="error" role="error">
            [ITS-MS-ID-00003][Error] The @tdf:version <sch:value-of select="./@tdf:version"/> is less than the minimum version 
            allowed: 2014-DEC (201412). 
            
            Human Readable: The IC-TDF version imported by ITS-MS must be greater than or equal to 2014-DEC (201412). 
        </sch:assert>
    </sch:rule>
</sch:pattern>