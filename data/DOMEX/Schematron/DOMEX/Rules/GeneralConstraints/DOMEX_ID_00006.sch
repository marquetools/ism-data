<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!-- artf14833 - Validate sub-agency codes against DOMEX CVEs  -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00006">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00006][Error]
        Invalid sub-agency code. 
        
        Human Readable: Invalid sub-agency code.  
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        Given a primary agency, validate the sub-agency.
    </sch:p>
    <sch:rule id="DOMEX-ID-00006-R1" context="*[./domex:subAgency]">
        <sch:assert test="some $term in document(concat('../../CVE/DOMEX/CVEnumDOMEXAgency',substring-after(./domex:primaryAgency,'USA.'),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value              satisfies $term=./domex:subAgency"
            flag="error" role="error">
            [DOMEX_ID_00006] [Error] Invalid sub-agency code.
        </sch:assert>
    </sch:rule>
</sch:pattern>
