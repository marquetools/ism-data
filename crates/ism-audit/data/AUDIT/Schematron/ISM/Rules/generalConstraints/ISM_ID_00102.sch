<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00102" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00102][Error] The root element must have the attribute 
        DESVersion in the namespace urn:us:gov:ic:ism.
        
        Human Readable: The data encoding specification version number must be specified on the resource node.
    </sch:p>
    <sch:p id="codeDesc">
        The code checks that the root node has attribute DESVersion specified.
    </sch:p>
    <sch:rule context="/*">
        <sch:assert 
            id="ISM-00102" 
            test="
            ./@ism:DESVersion
            " 
            flag="error">
            [ISM-ID-00102][Error] The root element must have the attribute 
            DESVersion in the namespace urn:us:gov:ic:ism.
            
            Human Readable: The data encoding specification version number must be specified on the resource node.
        </sch:assert>
    </sch:rule>
</sch:pattern>