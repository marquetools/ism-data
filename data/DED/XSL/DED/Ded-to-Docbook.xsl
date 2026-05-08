<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:ded="urn:us:gov:ic:ded"
    xmlns:edh="urn:us:gov:ic:edh"
    exclude-result-prefixes="#all"
    xmlns:ism="urn:us:gov:ic:ism"
    xmlns:arh="urn:us:gov:ic:arh"
    xmlns:d="http://docbook.org/ns/docbook"
    version="2.0">
    
    <!--xsl:import href="../ISM/IC-ISM-SecurityBanner.xsl"/>
    <xsl:import href="../ISM/IC-ISM-PortionMark.xsl"/-->
    
    <!-- DAGON: test if saxon-he not supporting cast to list has to do with new ISM XSLs -->
    <xsl:import href="../ISM-Old/IC-ISM-SecurityBanner.xsl"/>
    <xsl:import href="../ISM-Old/IC-ISM-PortionMark.xsl"/>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 13, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> IC-CIO</xd:p>
            <xd:p>Convert a DED.xml instance document to Docbook for Rendering</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <xsl:output method="xml" indent="yes"/>

    <xd:doc>
        <xd:desc>Create the docbook book that is the data element dictionary</xd:desc>
    </xd:doc>
    <xsl:template match="ded:DataElementDictionary">
        <d:book version="5.0-ExtendForISM" xml:lang="en">
           
            <d:info>
               <!-- <d:author>
                    <d:personname>
                        <d:surname>
                            <xsl:value-of select="cve:IRM/cve:Source"/>
                        </d:surname>
                    </d:personname>
                </d:author>-->
                <d:releaseinfo><xsl:apply-templates select=".//arh:Security" mode="ism:banner"/></d:releaseinfo>

                <!-- <d:mediaobject xml:id="image_odni">
                    <d:imageobject>
                        <d:imagedata fileref="../../common/images/odni.jpg" width="1.59in" align="center"/>
                    </d:imageobject>
                </d:mediaobject>-->
                
                <d:title><xsl:apply-templates select="//ded:DedTitle" mode="ism:portionmark"/>Data Element Dictionary for <xsl:value-of select="//ded:DedTitle"/></d:title>
                <!--<d:edition>Version <xsl:value-of select="$spec.version"/></d:edition>-->
                <d:author>
                    <d:orgname>Prepared by <xsl:value-of select="//edh:ResponsibleEntity[@edh:role='Custodian']/edh:Organization"/></d:orgname>
                </d:author>
                
                <!--<d:pubdate>DraftDateReplaceMe</d:pubdate>
                <d:date>ReleaseDateReplaceMe</d:date>
                <d:address>Distribution Notice: 
           This document has been approved for Public Release and is available for use without restriction.
       </d:address>
                <d:releaseinfo>distFooterReplace</d:releaseinfo>-->
            </d:info>
            <d:chapter>
                <d:title>Data Elements</d:title>
                <xsl:for-each select="./ded:DataElement">
                    <xsl:sort select="ded:ElementName" order="ascending"/>
                    <xsl:apply-templates select="current()"/>
                </xsl:for-each>
            </d:chapter>
            <xsl:if test="./ded:Relationship">
                <d:chapter>
                    <d:title>Relationships</d:title>
                    <xsl:for-each select="./ded:Relationship">
                        <xsl:sort select="ded:RelationshipName" order="ascending"/>
                        <xsl:apply-templates select="current()"/>
                    </xsl:for-each>
                </d:chapter>
            </xsl:if>
            
            <d:index/>
        </d:book>
    </xsl:template>
    

    <xd:doc>
        <xd:desc>Create the DataElement section</xd:desc>
    </xd:doc>
    <xsl:template match="ded:DataElement">
        <d:section>
            <d:title><xsl:apply-templates select="ded:ElementName" mode="ism:portionmark"/><xsl:value-of select="ded:ElementName"/></d:title>
            <d:table frame="all" rowsep="1" colsep="1" xml:id="{ded:ElementName}">
                <d:title><xsl:apply-templates select="ded:ElementName" mode="ism:portionmark"/><xsl:value-of select="ded:ElementName"/></d:title>
                <d:indexterm>
                    <d:primary><xsl:value-of select="ded:ElementName"/></d:primary>
                </d:indexterm>
                <d:tgroup cols="2" align="left">
                    <d:colspec colname="c1" colnum="1" colwidth="1*"/>
                    <d:colspec colname="c2" colnum="2" colwidth="3*"/>
                    <d:thead>
                        <d:row>
                            <d:entry namest="c1" nameend="c2" align="center">
                                <d:para><xsl:apply-templates select="ded:ElementName" mode="ism:portionmark"/>The <xsl:value-of select="ded:ElementName"/> table is <xsl:apply-templates select="." mode="ism:banner"/></d:para>
                            </d:entry>
                        </d:row>
                        <d:row>
                            <d:entry><d:para>DED Field Name</d:para></d:entry>
                            <d:entry><d:para>Value</d:para></d:entry>
                        </d:row>
                    </d:thead>
                    <d:tbody>
                        <xsl:apply-templates select="./*">
                            <xsl:sort select="local-name()"/>
                        </xsl:apply-templates>
                        
                    </d:tbody>
                </d:tgroup>
            </d:table>
        </d:section>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Create the Relationship section</xd:desc>
    </xd:doc>
    <xsl:template match="ded:Relationship" priority="5">
        <d:section>
            <d:title><xsl:apply-templates select="ded:RelationshipName" mode="ism:portionmark"/><xsl:value-of select="ded:RelationshipName"/></d:title>
            <d:table frame="all" rowsep="1" colsep="1" xml:id="{ded:RelationshipName}">
                <d:title><xsl:apply-templates select="ded:RelationshpName" mode="ism:portionmark"/><xsl:value-of select="ded:RelationshipName"/></d:title>
                <d:indexterm>
                    <d:primary><xsl:value-of select="ded:RelationshipName"/></d:primary>
                </d:indexterm>
                <d:tgroup cols="2" align="left">
                    <d:colspec colname="c1" colnum="1" colwidth="1*"/>
                    <d:colspec colname="c2" colnum="2" colwidth="3*"/>
                    <d:thead>
                        <d:row>
                            <d:entry namest="c1" nameend="c2" align="center">
                                <d:para><xsl:apply-templates select="ded:RelationshipName" mode="ism:portionmark"/>The <xsl:value-of select="ded:RelationshipName"/> table is <xsl:apply-templates select="." mode="ism:banner"/></d:para>
                            </d:entry>
                        </d:row>
                        <d:row>
                            <d:entry><d:para>DED Field Name</d:para></d:entry>
                            <d:entry><d:para>Value</d:para></d:entry>
                        </d:row>
                    </d:thead>
                    <d:tbody>
                        <xsl:apply-templates select="./*">
                            <xsl:sort select="local-name()"/>
                        </xsl:apply-templates>
                    </d:tbody>
                </d:tgroup>
            </d:table>
        </d:section>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Create a table row for each child of a DataElement or Relationship</xd:desc>
    </xd:doc>
    <xsl:template match="ded:*[parent::ded:DataElement or parent::ded:Relationship]">
        <d:row>
            <d:entry><d:para><xsl:value-of select="local-name()"/></d:para></d:entry>
            <d:entry><d:para><xsl:choose>
                <xsl:when test="@ism:*">
                    <xsl:apply-templates select="." mode="ism:portionmark"/>
                </xsl:when>
                <xsl:otherwise><xsl:text>(U) </xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/></d:para></d:entry>
        </d:row>
    </xsl:template>

  
</xsl:stylesheet>