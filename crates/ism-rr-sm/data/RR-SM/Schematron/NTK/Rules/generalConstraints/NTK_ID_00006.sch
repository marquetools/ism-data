<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="NTK-ID-00006" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [NTK-ID-00006][Error]The attribute 
        DESVersion in the namespace urn:us:gov:ic:ntk must be specified.
        
        Human Readable: The data encoding specification version must
        be specified.
    </sch:p>
    
    <sch:p id="codeDesc">
        Make sure that the attribute ntk:DESVersion is specified.
    </sch:p>
    
    <sch:rule context="/">
        <sch:assert 
            test="some $element in descendant-or-self::node() satisfies $element/@ntk:DESVersion"
            flag="error">
            [NTK-ID-00006][Error] The attribute 
            DESVersion in the namespace urn:us:gov:ic:ntk must be specified.
            
            Human Readable: The data encoding specification version must 
            be specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>
