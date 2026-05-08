<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="ARH-ID-00004" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ARH-ID-00004][Error] The @ntk:DESVersion is less than the minimum version 
        allowed: 7. 
        
        Human Readable: The NTK version imported by ARH must be greater than 7. 
    </sch:p>
    <sch:p id="codeDesc">
        For all elements that contain @ntk:DESVersion, we verify that the version
        is greater than the minimum allowed version: 7.  
    </sch:p>
    <sch:rule context="*[@ntk:DESVersion]">
        <sch:assert  
            test="number(@ntk:DESVersion) >= 7"
            flag="error">
            [ARH-ID-00004][Error] The @ntk:DESVersion is less than the minimum version 
            allowed: 7. 
            
            Human Readable: The NTK version imported by ARH must be greater than 7.
        </sch:assert>
    </sch:rule>
</sch:pattern>
