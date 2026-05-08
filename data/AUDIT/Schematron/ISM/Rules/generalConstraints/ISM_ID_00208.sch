<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00208" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">[ISM-ID-00208][Warning] Attribute atomicEnergyMarkings contains a value that will be deprecated.</sch:p>
    <sch:p id="codeDesc">Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used prior to the deprecated date.</sch:p>

    <sch:rule context="*[@ism:atomicEnergyMarkings]">
        
        <sch:let name="depTerms" value="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
        <sch:let name="isError" value="false()"/>
        
        <sch:let name="reportWarn" value="
            dvf:deprecated(string(./@ism:atomicEnergyMarkings), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)
            "/>
        
        <sch:assert id="ISM-00208"
            test="count($reportWarn)=0"
            flag="warning">
            [ISM-ID-00208][Warning] For attribute atomicEnergyMarkings, value(s) <sch:value-of select="$reportWarn"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>