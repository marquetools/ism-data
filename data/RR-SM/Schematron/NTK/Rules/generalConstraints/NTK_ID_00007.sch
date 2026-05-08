<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="NTK-ID-00007" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [NTK-ID-00007][Error] The attribute @ntk:externalReference must be set to 
        true when the ExternalAccess element is used.
        
    </sch:p>
    
    <sch:p id="codeDesc">
        Make sure the externalReference attribute is specified with a value of
        true when the ExternalAccess element is used.
    </sch:p>
    
    <sch:rule context="ntk:ExternalAccess">
        <sch:assert 
            test="@ntk:externalReference=true()"
            flag="error">
            [NTK-ID-00007][Error] The attribute @ntk:externalReference must be set to 
            true when the ExternalAccess element is used.
        </sch:assert>
    </sch:rule>
</sch:pattern>
