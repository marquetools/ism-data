<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00163" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00163][Error] If attribute nonUSControls exists the attribute ownerProducer must equal [NATO].
        
        Human Readable: NATO is the only owner of classification markings for which nonUSControls are currently authorized.
    </sch:p>
    <sch:p id="codeDesc">
        The code ensures that any element containing the attribute nonUSControls also has 
        attribute ownerProducer specified with a value of [NATO].
    </sch:p>
    <sch:rule context="*[@ism:nonUSControls]">
        <sch:assert 
            id="ISM-00163" 
            test="./@ism:ownerProducer='NATO'"
            flag="error">
            [ISM-ID-00163][Error] NATO is the only owner of classification markings for which nonUSControls are currently authorized.
        </sch:assert>
    </sch:rule>
</sch:pattern>