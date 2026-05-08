<?xml version="1.0" encoding="UTF-8"?>
<sch:pattern id="ISM-ID-00195" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:p id="ruleText">[ISM-ID-00195][Error] Attribute notice must not contain values that have passed their deprecation date.</sch:p>
    <sch:p id="codeDesc">Traverse the CVE file pulling out deprecated values and their dates. Using the ism:createDate determine if the values are
        being used passed the deprecated date.</sch:p>

    <sch:rule context="*[@ism:noticeType]">
        
        <sch:let name="depTerms" value="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated]"/>
        <sch:let name="isError" value="true()"/>
        
        <sch:let name="reportErr" value="
            dvf:deprecated(string(./@ism:noticeType), $depTerms, $ISM_RESOURCE_CREATE_DATE, $isError)
            "/>
        
        <sch:assert id="ISM-00195"
            test="count($reportErr)=0"
            flag="error">
            [ISM-ID-00195][Error] For attribute notice, value(s) <sch:value-of select="$reportErr"/>
        </sch:assert>
    </sch:rule>
</sch:pattern>