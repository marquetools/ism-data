<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="NTK-ID-00009" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [NTK-ID-00009][Error] The @ism:DESVersion is less than the minimum version 
        allowed: 9. 
        
        Human Readable: The ism version imported by NTK must be greater than or equal to 9. 
    </sch:p>
    <sch:p id="codeDesc">
        For all elements that contain @ism:DESVersion, we verify that the version
        is greater than or equal to the minimum allowed version: 9.  
    </sch:p>
    <sch:rule context="*[@ism:DESVersion]">
        <sch:assert  
            test="number(@ism:DESVersion) >= 9"
            flag="error">
            [NTK-ID-00009][Error] The @ism:DESVersion is less than the minimum version 
            allowed: 9. 
            
            Human Readable: The ism version imported by NTK must be greater than or equal to 9.
        </sch:assert>
    </sch:rule>
</sch:pattern>
