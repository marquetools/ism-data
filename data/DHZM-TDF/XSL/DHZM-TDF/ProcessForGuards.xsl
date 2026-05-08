<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:ism="urn:us:gov:ic:ism"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 13, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> bob</xd:p>
            <xd:p>Remove comments, PIs annotations, defaults (minOccurs="1" or maxOccurs="1"), ISM attributes to make the smallest simple file for a guard.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"  encoding="utf-8" /> 
    <xsl:strip-space elements="*"/>
    
    <xd:doc>
        <xd:desc>Add processing instruction to skip the unit test that checks for proper Processing Instructions on schema files.</xd:desc>
    </xd:doc>
    <xsl:template match="/*">
        <xsl:processing-instruction name="skip-unit-test-PI-validation"></xsl:processing-instruction>
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>Identity Transform</xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()">       
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Strip out all @minOccurs and @maxOccurs whose value is 1 as those are defined by XSD specification to be the default.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@minOccurs[.=1] | @maxOccurs[.=1]"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Strip out all @ism:* as the ISM attributes are only there for describing the DES</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@ism:*"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Strip out all comments, PIs and xs:annotations.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="comment()|processing-instruction()|xs:annotation" priority="5"/>
</xsl:stylesheet>