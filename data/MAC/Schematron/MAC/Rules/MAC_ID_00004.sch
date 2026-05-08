<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="MAC-ID-00004">
    <sch:p class="ruleText">[MAC-ID-00004][Error] The @mime:CESVersion is less than the minimum version 
        allowed: 201609. 
        
        Human Readable: The MIME version imported by MAC must be greater than or equal to 2016-SEP.</sch:p>
    
    <sch:p class="codeDesc">For all elements that contain @mime:CESVersion, we verify that the version
        is greater than or equal to the minimum allowed version: 201609.</sch:p>
    
    <sch:rule context="*[@mime:CESVersion]">
        <sch:let name="version" value="number(if (contains(@mime:CESVersion,'-')) then substring-before(@mime:CESVersion,'-') else @mime:CESVersion)"/>
        <sch:assert test="$version &gt;= 201609" flag="error">The @mime:CESVersion is less than the minimum version 
            allowed: 201609. 
            
            Human Readable: The MIME version imported by MAC must be greater than or equal to 2016-SEP.</sch:assert>
    </sch:rule>
</sch:pattern>