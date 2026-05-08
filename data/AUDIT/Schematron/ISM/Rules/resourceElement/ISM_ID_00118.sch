<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00118" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00118][Error] The first element in document order having 
        resourceElement true must have createDate specified.
    </sch:p>
    <sch:p id="codeDesc">
        We make sure that the resourceElement has attribute createDate specified.
    </sch:p>
    <sch:rule context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]">
        <sch:assert 
            id="ISM-00118" 
            test="
            if(./@ism:createDate) then true() else false()
            " 
            flag="error">
            [ISM-ID-00118][Error] The first element in document order having 
            resourceElement true must have createDate specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>