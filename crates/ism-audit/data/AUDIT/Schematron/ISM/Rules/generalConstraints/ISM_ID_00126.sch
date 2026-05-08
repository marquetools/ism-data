<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00126" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
        not appear with attribute @xs:any. 
        
        Human Readable: Ensure that no attributes that appear to be in the ISM namespace, but are not 
        defined by ISM.XML, are used in a schema that might have an xs:any.
    </sch:p>
    <sch:p id="codeDesc">
        The code checks that any element having ISM attributes does not have the attribute xs:any specified.
    </sch:p>
    <sch:rule context="*[@ism:*]">
        <sch:assert 
            id="ISM-00126" 
            test="
            not(./@xs:any)
            "
            flag="error">
            [ISM-ID-00126][Error] Attributes with namespace urn:us:gov:ic:ism must 
            not appear with attribute @xs:any. 
        </sch:assert>
    </sch:rule>
</sch:pattern>