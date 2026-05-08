<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="DOMEX-ID-00011" is-a="ValidateValidationEnvSchema">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        [DOMEX-ID-00011][Error] Regardless of the version indicated on the instance document, 
        the validation infrastructure MUST use a version of 'IC-EDH' that is version '201903' (Version:2019-MAR) or later. 
        NOTE: This is not an error of the instance document but of the validation environment itself. 
    </sch:p>
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:ownerProducer="USA" ism:classification="U" class="ruleText">
        This rule uses an abstract pattern to consolidate logic. 
        It verifies that the validation infrastructure is using the version specified in parameters.
    </sch:p>
    <sch:param name="MinVersion" value="'201903'"/>
    <sch:param name="SpecToCheck" value="'IC-EDH'"/>
    <sch:param name="pathToDocument" value="'../../Schema/IC-EDH/IC-EDH.xsd'"/>
    <sch:param name="RuleID" value="'DOMEX-ID-00011'"/>
</sch:pattern>