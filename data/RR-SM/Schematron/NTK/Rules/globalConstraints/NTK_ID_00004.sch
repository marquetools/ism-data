<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?> 
 <!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern id="NTK-ID-00004" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [NTK-ID-00004][Error] Every attribute in the NTK namespace must be
        specified with a non-whitespace value.
    </sch:p>
    
    <sch:p id="codeDesc">
        For each element which specifies an attribute in the NTK namespace, we
        make sure that all attributes in the NTK namespace contain a non-whitespace
        value.
    </sch:p>
    
    <sch:rule context="*[@ntk:*]">
        <sch:assert 
            test="every $attribute in @ntk:* satisfies
            		normalize-space(string($attribute))"
            flag="error">
            [NTK-ID-00004][Error] Every attribute in the document must be specified with a non-whitespace value.
        </sch:assert>
    </sch:rule>
</sch:pattern>