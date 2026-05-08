<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!-- artf14833 - Validate country codes against GENC CVEs  -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00005">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00005][Error]
        Invalid GENC code. 
        
        Human Readable: Invalid GENC code.  
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        Invokes GENC AllowableGencValues abstract pattern to validate GENC country code.
    </sch:p>
    <sch:rule id="DOMEX-ID-00005-R1" context="*[@irm:codespace]">
        <sch:assert test="some $term in document(concat('../../CVE/IC-GENC/CVEnum',upper-case(substring(./@irm:codespace,1,1)),translate(substring(./@irm:codespace,2),':',''),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value              satisfies $term=./@irm:code"
            flag="error" role="error">
            [DOMEX_ID_00005] [Error] Invalid GENC code.
        </sch:assert>
    </sch:rule>
</sch:pattern>
