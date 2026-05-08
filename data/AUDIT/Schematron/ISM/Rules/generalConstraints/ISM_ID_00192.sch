<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00192" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">[ISM-ID-00192][Warning] Attribute nonICmarkings contains a value that will be deprecated.</sch:p>
    <sch:p id="codeDesc">Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate, determine if the values are
        being used but it is still prior to the deprecated date</sch:p>

    <sch:rule context="*[@ism:nonICmarkings]">
        
        <sch:let name="depTerms" value="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
        <sch:let name="isError" value="false()"/>
        
        <sch:let name="reportWarn" value="
            dvf:deprecated(string(./@ism:nonICmarkings), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)
            "/>
        
        <sch:assert id="ISM-00192"
            test="count($reportWarn)=0"
            flag="warning">
            [ISM-ID-00192][Warning] For attribute nonICmarkings, value(s) <sch:value-of select="$reportWarn"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>