<?xml version="1.0" encoding="utf-8"?>
<sch:pattern id="ISM-ID-00002" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00002][Error] For every optional attribute that is used in a document a non-null value must be present.
    </sch:p>
    <sch:p id="codeDesc">
        This code checks that if an attribute is present and has an empty or whitespace string as a value, then
        we return false since all attributes must have a value specified.
    </sch:p>
    <sch:rule context="*[@ism:*]">
        <sch:assert 
            id="ISM-00002" 
            test="
                every $attribute in ./@ism:* satisfies
                    not(normalize-space(string($attribute)) = '')
            " 
            flag="error">
            [ISM-ID-00002][Error] For every optional attribute that is used in a document a non-null value must be present.
        </sch:assert>
    </sch:rule>
</sch:pattern>