<?xml version="1.0" encoding="UTF-8"?>
<?ICEA pattern?>
<!-- Notices - Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       -->
<sch:pattern xmlns:sch="http://purl.oclc.org/dsdl/schematron" id="CEM-ID-00005">
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="ruleText">
        [CEM-ID-00005][Warning] For every optional element that exists
        and can have text content, the element should have non-null, 
        non-whitespace value.
    </sch:p>
    
    <sch:p xmlns:ism="urn:us:gov:ic:ism" ism:classification="U" ism:ownerProducer="USA" class="codeDesc">
        This pattern uses an abstract rule to consolidate logic. The abstract rule
        first concatenates the text values within the given element, separated by a single 
        space. The resultant string is then normalized with leading and trailing 
        whitespace removed, and the length of the string is determined to be greater 
        than zero, which indicates non-whitespace content. The abstract rule is extended 
        once for each optional element in the CEM schema.  
    </sch:p>
    
    <sch:rule abstract="true" id="abs.rule00001">
        <sch:assert test="normalize-space(string())" flag="warning">
            [CEM-ID-00005][Warning] For every optional element that exists
            and can have text content, the element should have non-null, 
            non-whitespace value.
        </sch:assert>
    </sch:rule>
    
    <!-- Begin using abstract rule on optional elements -->
    
    <!-- mixed='true' -->
    <sch:rule context="cem:Drug">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <!-- Extensions of RunningTextType -->
    <sch:rule context="cem:Account">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:CommData">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>

    <sch:rule context="cem:CityName">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Commodity">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Concept">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:CountryName">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Date">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:DateTime">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:EntityUntyped">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Equipment">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Event">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Facility">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:GeoFeature">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:GeoRef">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Identifier">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:InfoBearer">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:LocationOfInterest">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:MilitaryUnit">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Money">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Nomenclature">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Organization">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Person">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:QuantityReference">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>

    <sch:rule context="cem:SystemClass">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Term">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Time">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:TransportationNetwork">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Vehicle">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>
    
    <sch:rule context="cem:Weapon">
        <sch:extends rule="abs.rule00001"/>
    </sch:rule>

</sch:pattern>
