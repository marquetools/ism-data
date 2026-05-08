<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="RR-SM-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [RR-SM-ID-00002][Error] The @arh:DESVersion is less than the minimum version 
        allowed: 1. 
        
        Human Readable: The arh version imported by RR-SM must be greater than or equal to 1. 
    </sch:p>
    <sch:p id="codeDesc">
        For all elements that contain @arh:DESVersion, we verify that the version
        is greater than or equal to the minimum allowed version: 1.  
    </sch:p>
    <sch:rule context="*[@arh:DESVersion]">
        <sch:assert  
            test="number(@arh:DESVersion) >= 1"
            flag="error">
            [RR-SM-ID-00002][Error] The @arh:DESVersion is less than the minimum version 
            allowed: 1. 
            
            Human Readable: The arh version imported by RR-SM must be greater than or equal to 1. 
        </sch:assert>
    </sch:rule>
</sch:pattern>
