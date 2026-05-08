<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ism="urn:us:gov:ic:ism" 
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs"
    version="2.0">
    
    
    <!-- ================================================== -->
    <!--                     IMPORTS                        -->
    <!-- ================================================== -->
    <xsl:import href="../../ISM/IC-ISM-SecurityBanner.xsl"/>
    <xsl:import href="../../ISM/IC-ISM-PortionMark.xsl"/>
    <xsl:import href="../../ISM/IC-ISM-ClassDeclass.xsl"/>
    
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 20, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> ODNI/IC CIO</xd:p>
            <xd:p>This xsl is to be run before the Docbook document 
                is processed into FO or HTML. It renders the ISM 
                into the docbook text as a preprocessing step before
                converting to FO.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" method="xml"/>
    
    
    <!-- ================================================== -->
    <!--                      PARAMS                        -->
    <!-- ================================================== -->
    

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Will retain the ISM if set to true. This is
                useful for debug purposes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="retainISM" select="false()"/>
    
    
    <!-- ================================================== -->
    <!--                    VARIABLES                       -->
    <!-- ================================================== -->
    
    <xsl:variable name="bannerText">
        <xsl:apply-templates select="/d:*[@ism:*]" mode="ism:banner"/>
    </xsl:variable>
    
    <xsl:variable name="declassBlock">
        <xsl:apply-templates select="/d:*[@ism:*]" mode="ism:authority"/>
    </xsl:variable>
    
    <!-- ================================================== -->
    <!--                     TEMPLATES                      -->
    <!-- ================================================== -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Add a USA NSI Banner releaseinfo element that reflects the banner's
                ISM to the documents info if none exists.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/d:*/d:info">
        <xsl:copy>
            <xsl:apply-templates select="@* | node() except d:releaseinfo[@role='usa.nsi.banner' or @role='usa.nsi.block']"/>
            <xsl:element name="releaseinfo" namespace="http://docbook.org/ns/docbook">
                <xsl:attribute name="role" select="'usa.nsi.banner'"/>
                <xsl:value-of select="$bannerText"/>
            </xsl:element>
            <xsl:if test="/d:*[not(@ism:classification='U')]">
                <xsl:element name="releaseinfo" namespace="http://docbook.org/ns/docbook">
                    <xsl:attribute name="role" select="'usa.nsi.block'"/>
                    <xsl:value-of select="$declassBlock"/>
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Update the releaseinfo element that holds the USA NSI banner 
            so that it reflects the ISM values fromt the root.</xd:p>
        </xd:desc>
    </xd:doc>
    <!--<xsl:template match="d:releaseinfo[@role='usa.nsi.banner']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="$bannerText"/>
        </xsl:copy>
    </xsl:template>-->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Converts ISM on docbook elements into portion marks.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="d:title[@ism:*] | d:para[@ism:*]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @ism:*"/>
            <xsl:if test="$retainISM">
                <xsl:apply-templates select="@ism:*"/>
            </xsl:if>
            <xsl:apply-templates select="." mode="ism:portionmark"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Identity Transform to preserve all attributes
            and nodes that do not have specific handling.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>