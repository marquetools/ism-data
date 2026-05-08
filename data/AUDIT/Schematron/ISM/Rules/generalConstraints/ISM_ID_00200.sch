<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00200" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">[ISM-ID-00200][Warning] Attribute displayOnlyTo contains a value that will be deprecated.</sch:p>
    <sch:p id="codeDesc">Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate date, determine if the values are
        being used but it is still prior to the deprecated date</sch:p>
 
    <sch:rule context="*[@ism:displayOnlyTo]">
        
        <sch:let name="depTerms" value="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
        <sch:let name="isError" value="false()"/>
        
        <sch:let name="reportWarn" value="
            dvf:deprecated(string(./@ism:displayOnlyTo), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)
            "/>
        
        <sch:assert id="ISM-00200"
            test="count($reportWarn)=0"
            flag="warning">
            [ISM-ID-00200][Warning] For attribute displayOnlyTo, value(s) <sch:value-of select="$reportWarn"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>