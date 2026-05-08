<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<!-- Issue #889 - Validate sub-activity codes against DOMEX CVEs  -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00007">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX_ID_00007][Error]
        Invalid sub-activiy specified. 
        
        Human Readable: Invalid sub-activiy specified.  
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="codeDesc">
        Given a primary activity, validate the sub-activity.
    </sch:p>
    <sch:rule id="DOMEX-ID-00007-R1" context="domex:subActivity">
        <sch:assert test="some $term in document(concat('../../CVE/DOMEX/CVEnumDOMEXActivity',translate(../domex:primaryActivity,' ,',''),'.xml'))//cve:CVE/cve:Enumeration/cve:Term/cve:Value satisfies $term=."
            flag="error" role="error">
            [DOMEX_ID_00007] [Error] Invalid sub-activity specified.
        </sch:assert>
    </sch:rule>
</sch:pattern>
