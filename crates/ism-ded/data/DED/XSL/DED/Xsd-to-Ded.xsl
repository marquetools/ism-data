<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:ded="urn:us:gov:ic:ded"
    xmlns:ism="urn:us:gov:ic:ism" 
    xmlns:arh="urn:us:gov:ic:arh"
    xmlns:edh="urn:us:gov:ic:edh"
    xmlns:icid="urn:us:gov:ic:id"
    xmlns:usagency="urn:us:gov:ic:usagency"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xhtml="http://www.w3.org/1999/xhtml-StopBrowserRendering"    
    exclude-result-prefixes="xs xd xhtml"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 12, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b>IC-CIO</xd:p>
            <xd:p>Given an XSD with annotation documentation markup using the attribute data-ded to identify DED elements create a DED XML file from it. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes"/>
    
    <xsl:param name="edhDESVersion" select="201903"/>
    <xsl:param name="usagencyCESVersion" select="202111"/>
    <xsl:param name="icidDESVersion" select="1"/>
    <xsl:param name="dedDESVersion" select="201903"/>
    
    <xd:doc>
        <xd:desc>Start at the beginning of the schema and run only on documentation with DedTitle</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">href="../../Schematron/IC-EDH/IC-EDH_XML.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">href="../../Schematron/ISM/ISM_XML.sch" type="application/xml" schematypens=http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">href="../../Schematron/USAgency/USAgency_XML.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">href="../../Schematron/DED/DED_XML.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">href="../../Schematron/IC-ID/IC-ID_XML.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        
        <xsl:apply-templates select="//xsd:documentation[descendant::xhtml:p/@data-ded='ded:DedTitle']"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>This is the "master" documentation it is the start of everything and the DED information on this entire DED.</xd:desc>
    </xd:doc>
    <xsl:template match="xsd:documentation[descendant::xhtml:div/@data-ded='ded:DataElementDictionary']">
        <ded:DataElementDictionary ded:DESVersion="{$dedDESVersion}" icid:DESVersion="{$icidDESVersion}" 
            xsi:schemaLocation="urn:us:gov:ic:ded ../../Schema/DED/DED.xsd">
            <ded:DedHeader>
            <edh:Edh edh:DESVersion="{$edhDESVersion}" usagency:CESVersion="{$usagencyCESVersion}">
                    <icid:Identifier>
                        <xsl:value-of select="normalize-space(substring-after(descendant::xhtml:p[@data-ded='ded:DedId'],' '))"/>
                    </icid:Identifier>
                    <edh:DataItemCreateDateTime>
                        <xsl:value-of select="normalize-space(substring-after(descendant::xhtml:p[@data-ded='ded:DedDate'],' '))"/>
                    </edh:DataItemCreateDateTime>
                    <edh:ResponsibleEntity edh:role="Custodian">
                        <edh:Country>USA</edh:Country>
                        <edh:Organization>
                            <xsl:value-of select="concat('USA.', normalize-space(substring-after(descendant::xhtml:p[@data-ded='ded:DedResponsibleAgency'],' ')))"/>
                        </edh:Organization>
                    </edh:ResponsibleEntity>
                    <arh:Security>
                        <xsl:copy-of select="./descendant::xhtml:div[@data-ded='ded:DataElementDictionary']/@ism:*"/>
                        <xsl:if test="./descendant::xhtml:p[@data-ded='ded:DedDistroStatement']">
                            <ism:NoticeList>
                                <xsl:copy-of select="./descendant::xhtml:p[@data-ded='ded:DedDistroStatement']/@ism:*"/>
                                <ism:Notice ism:unregisteredNoticeType="distroStatement">
                                    <xsl:copy-of select="./descendant::xhtml:p[@data-ded='ded:DedDistroStatement']/@ism:*"/>
                                    <ism:NoticeText>
                                        <xsl:copy-of select="./descendant::xhtml:p[@data-ded='ded:DedDistroStatement']/@ism:*"/>
                                        <xsl:value-of select="normalize-space(substring-after(./descendant::xhtml:p[@data-ded='ded:DedDistroStatement'],' '))"/>
                                    </ism:NoticeText>
                                </ism:Notice>
                            </ism:NoticeList>
                        </xsl:if>
                    </arh:Security>
                </edh:Edh>
                
                <xsl:apply-templates select="descendant::xhtml:p[@data-ded and not(@data-ded='ded:DedId' or @data-ded='ded:DedDate' or @data-ded='ded:DedDistroStatement' or @data-ded='ded:DedResponsibleAgency')]"/>
            </ded:DedHeader>
            
            <xsl:apply-templates select="//xsd:documentation[descendant::xhtml:div/@data-ded='ded:DataElement']">
                
            </xsl:apply-templates>
        </ded:DataElementDictionary>
    </xsl:template>

    <xd:doc>
        <xd:desc>Create DataElements for each part of schema that is defined as such in documentation</xd:desc>
    </xd:doc>
    <xsl:template match="xsd:documentation[descendant::xhtml:div/@data-ded='ded:DataElement']">
        <ded:DataElement>
            <xsl:copy-of select="./descendant::xhtml:div[@data-ded='ded:DataElement']/@ism:*"/>
            <xsl:apply-templates select="descendant::xhtml:p[@data-ded]"/>
        </ded:DataElement>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Process schema documentation xhtml:p tags that have specific ded documentation components.</xd:desc>
    </xd:doc>
    <xsl:template match="xhtml:p[@data-ded]|xhtml:span[@data-ded]">
        <xsl:element name="{@data-ded}" namespace="urn:us:gov:ic:ded">
            <xsl:if test="not(@data-ded='ded:ElementId' or @data-ded='ded:DedVersion' or @data-ded='ded:DedShortName' or @data-ded='ded:DedSubjectType')">
                <xsl:copy-of select="@ism:*"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="descendant::xhtml:span">
                    <xsl:apply-templates select="descendant::xhtml:span[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="text()[normalize-space()]" mode="renderElementContent">
                        <xsl:with-param name="elementName" select="@data-ded"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:element>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Process text content of documentation to append element name if applicable</xd:desc>
        <xd:param name="elementName">Name of element to be prefixed on text content.</xd:param>
    </xd:doc>
    <xsl:template match="text()" mode="renderElementContent">
        <xsl:param name="elementName"/>
        <xsl:choose>
            <xsl:when test="contains(.,$elementName)">
                <xsl:value-of select="normalize-space(substring-after(., concat($elementName,':')))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>If something was not explicitly matched by another template, ignore it</xd:desc>
    </xd:doc>
    <xsl:template match="*" priority="0"/>
    
</xsl:stylesheet>