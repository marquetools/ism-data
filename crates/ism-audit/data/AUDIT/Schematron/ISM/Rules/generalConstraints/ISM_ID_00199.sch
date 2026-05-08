<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00199" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">[ISM-ID-00199][Error] Attribute releasableTo must not contain values that have passed their deprecation date.</sch:p>
    <sch:p id="codeDesc">Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</sch:p>

    <sch:rule context="*[@ism:releasableTo]">
        
        <sch:let name="depTerms" value="document('../../CVE/ISM/CVEnumISMRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
        <sch:let name="isError" value="true()"/>
        
        <sch:let name="reportErr" value="
            dvf:deprecated(string(./@ism:releasableTo), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)
            "/>
        
        <sch:assert id="ISM-00199"
            test="count($reportErr)=0"
            flag="error">
            [ISM-ID-00199][Error] For attribute releasableTo, value(s) <sch:value-of select="$reportErr"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>