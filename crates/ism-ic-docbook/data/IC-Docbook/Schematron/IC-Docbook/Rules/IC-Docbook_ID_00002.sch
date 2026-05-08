<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="IC-Docbook-ID-00002">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [IC-Docbook-ID-00002][Error] The @ism:DESVersion is less than the minimum version 
        allowed: 13. 
        
        Human Readable: The ISM version imported by IC-Docbook must be greater than or equal to 13. 
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        For all elements that contain @ism:DESVersion, this rule verifies that the version
        is greater than or equal to the minimum allowed version: 13.  
    </sch:p>
    <sch:rule id="IC-Docbook-ID-00002-R1" context="*[@ism:DESVersion]">
        <sch:let name="version" value="number(if (contains(@ism:DESVersion,'-')) then substring-before(@ism:DESVersion,'-') else @ism:DESVersion)"/>
        <sch:assert test="$version &gt;= 13" flag="error" role="error">
            [IC-Docbook-ID-00002][Error] The @ism:DESVersion is less than the minimum version 
            allowed: 13. 
            
            Human Readable: The ISM version imported by IC-Docbook must be greater than or equal to 13. 
        </sch:assert>
    </sch:rule>
</sch:pattern>