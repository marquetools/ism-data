<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:ism="urn:us:gov:ic:ism" id="ITS-OM-ID-00001">
    <sch:p class="ruleText" ism:classification="U" ism:ownerProducer="USA">
        [ITS-OM-ID-00001][Error] The @ism:DESVersion is less than the minimum version 
        allowed: 201412. 
        
        Human Readable: The ism version imported by ITS-OM must be greater than or equal to 201412.
    </sch:p>
    <sch:p class="codeDesc" ism:classification="U" ism:ownerProducer="USA">
        For all elements that contain @ism:DESVersion, this rule verifies that the version
        is greater than or equal to the minimum allowed version: 201412.  
    </sch:p>
    <sch:rule context="*[@ism:DESVersion]">
        <sch:let name="version" value="number(if (contains(@ism:DESVersion,'-')) then substring-before(@ism:DESVersion,'-') else @ism:DESVersion)"/>
        <sch:assert test="$version &gt;= 201412" flag="error">
            [ITS-OM-ID-00001][Error] The @ism:DESVersion is less than the minimum version 
            allowed: 201412. 
            
            Human Readable: The ism version imported by ITS-OM must be greater than or equal to 201412. 
        </sch:assert>
    </sch:rule>
</sch:pattern>
