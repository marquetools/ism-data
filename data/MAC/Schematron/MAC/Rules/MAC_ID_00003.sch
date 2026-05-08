<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="MAC-ID-00003">
    <sch:p class="ruleText">[MAC-ID-00003][Error] The @tdf:version is less than the minimum version 
        allowed: 3. 
        
        Human Readable: The TDF version imported by MAC must be greater than or equal to 3.
    </sch:p>
    
    <sch:p class="codeDesc">For all elements that contain @tdf:version, we verify that the version
        is greater than or equal to the minimum allowed version: 3. </sch:p>
    
    <sch:rule context="*[@tdf:version]">
        <sch:let name="version" value="number(if (contains(@tdf:version,'-')) then substring-before(@tdf:version,'-') else @tdf:version)"/>
        <sch:assert test="$version &gt;= 3" flag="error">
            [MAC-ID-00003][Error] The @tdf:version is less than the minimum version 
            allowed: 3. 
            
            Human Readable: The TDF version imported by MAC must be greater than or equal to 3.
        </sch:assert>
    </sch:rule>
</sch:pattern>
