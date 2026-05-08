<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00223" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    
    <sch:p id="ruleText">
        [ISM-ID-00223][Error] If any elements in namespace 
        urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml. 
        
        Human Readable: Ensure that elements in the ISM namespace are defined by ISM.XML.
    </sch:p>
    <sch:p id="codeDesc">
        To determine the valid values, this rule first retrieves the list of 
        valid element names as defined in CVEnumISMElements.xml. The test will 
        pass if there exists in the list an element name that matches the name
        of the current element. 
    </sch:p>

    <sch:rule context="ism:*[$ISM_CAPCO_RESOURCE]">
        <!-- Define variables -->    
        <sch:let name="errMsg_ValueNotFound" value="'
            [ISM-ID-00223][Error] If any elements in namespace 
            urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml.
        '"/>
        
        <sch:let name="localName" value="local-name()"/>
        
        <!-- Execute tests --> 
        <sch:assert id="ISM-00223" flag="error"
            test="exists($validElementList[text() = $localName])">
            <sch:value-of select="normalize-space(string($errMsg_ValueNotFound))"/>
            Invalid value of [<sch:value-of select="name()"/>]</sch:assert>
        
    </sch:rule>
</sch:pattern>