<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00003">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00003][Error] String length constraint violation - (element) 
        
        Human Readable: String length constraint violation - (element).
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        Checks string lengths for selected DOMEX elements in the IRM assertion.
    </sch:p>
    <sch:rule context="irm:description" id="DOMEX-ID-00003-R1">
        <sch:assert test="string-length(text()) &lt;= 4000" flag="error" role="error">
            [DOMEX_ID_00003][Error] String length constraint violation - (irm:description)
            
            Human Readable: String length constraint violation - (irm:description)
        </sch:assert>
    </sch:rule>
</sch:pattern>
