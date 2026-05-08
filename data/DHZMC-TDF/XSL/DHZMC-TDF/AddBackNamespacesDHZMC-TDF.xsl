<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 13, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> bob</xd:p>
            <xd:p>Add back DHZMC-TDF namespaces after processing DHZMC-TDF schema for guards.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"  encoding="US-ASCII" /> 
    <xsl:strip-space elements="*"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Template match on xs:schema element</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xs:schema">
        <xsl:copy>
            <xsl:namespace name="" select="'urn:us:gov:ic:tdf'"></xsl:namespace>
            <xsl:namespace name="dhzm" select="'urn:us:gov:ic:digitalhazmat'"></xsl:namespace>
            <xsl:namespace name="sfhashv" select="'urn:us:gov:ic:sf:hashverification'"></xsl:namespace>
            <xsl:namespace name="sf" select="'urn:us:gov:ic:sf'"></xsl:namespace>
            <xsl:namespace name="anlys" select="'urn:us:gov:ic:anlysassert'"></xsl:namespace>
            <xsl:namespace name="tdfsigal" select="'urn:us:gov:ic:cvenum:tdf:signaturealgorithm'"></xsl:namespace>
            <xsl:namespace name="tdfstate" select="'urn:us:gov:ic:cvenum:tdf:state'"></xsl:namespace>
            <xsl:namespace name="tdfhashal" select="'urn:us:gov:ic:cvenum:tdf:hashalgorithm'"></xsl:namespace>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Identity template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>