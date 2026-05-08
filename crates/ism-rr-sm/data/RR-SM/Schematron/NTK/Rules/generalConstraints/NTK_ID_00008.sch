<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="NTK-ID-00008" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [NTK-ID-00008][Error] If @ntk:access is used there must be a ntk:Access element present to convey the document level NTK.
        
    </sch:p>
    
    <sch:p id="codeDesc">
        Make sure ntk:Access element exists if @ntk:access exists in the document.
    </sch:p>
    
    <sch:rule context="*[@ntk:access]">
        <sch:assert 
            test="//ntk:Access | //ntk:ExternalAccess"
            flag="error">
            [NTK-ID-00008][Error] If @ntk:access is used there must be a ntk:Access element present to convey the document level NTK.
        </sch:assert>
    </sch:rule>
</sch:pattern>
