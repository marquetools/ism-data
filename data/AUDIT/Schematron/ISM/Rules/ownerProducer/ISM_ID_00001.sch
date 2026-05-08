<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00001" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">
        [ISM-ID-00001][Error] The attribute ownerProducer, when it exists, must have
        a non-null value.
    </sch:p>
    <sch:p id="codeDesc">
        This code makes sure that if ownerProducer is specified that it contains
        content that is a non-whitespace value.
    </sch:p>
    <sch:rule context="*[@ism:ownerProducer]">
        <sch:assert 
            id="ISM-00001" 
            test="normalize-space(string(./@ism:ownerProducer))!=''" 
            flag="error">
            [ISM-ID-00001][Error] The attribute ownerProducer, when it exists, must have
            a non-null value.
        </sch:assert>
    </sch:rule>
</sch:pattern>