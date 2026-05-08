<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xl="http://www.w3.org/1999/xlink"
   xmlns:fo="http://www.w3.org/1999/XSL/Format"
   xmlns:ism="urn:us:gov:ic:ism" xmlns:d="http://docbook.org/ns/docbook" version="2.0">

   <!-- This customization layer aims to modify the generated output of the 
        default docbook xsl FO transform, and thus the output of FOP ODF output.
        
        Simple customizations with self-explanatory parameter names and attribute 
        sets are typically grouped together with a simple comment description of the group.
        
        For more complex customizations that typically replace template matches in the 
        default docbook xsl, comments that describe what the change is, how the change 
        was made, and why the change was made, are placed above the blocks of code that 
        have been modified.
    -->
   
   <!--Indicates the location of the base 5EE FO XSL.  Change if needed-->
   <xsl:import href="BannerFOcustomizationlayer.xsl"/>
   
   <!-- Use a custom title page format generated from template -->
   <xsl:import href="FOcustomtitle.xsl"/>
   
   <!-- Use the ISM portion mark rendering stylesheet to render ISM portion marks -->
   <xsl:import href="../../ISM/IC-ISM-PortionMark.xsl"/>

   <!--Indentation makes troubleshooting the FO much easier ;) -->
   <!--Indentation breaks the syntax highlighting of the code. Leave off unless debugging -->
   <xsl:output method="xml" encoding="UTF-8" indent="no"/>

   
   <!--General text formatting-->
   <xsl:param name="alignment">left</xsl:param>
   <xsl:param name="hyphenate">false</xsl:param>

   <!-- fix wrapping of long numbers -->
   <xsl:param name="orderedlist.label.width">2.0em</xsl:param>

   <!--Font customization-->
   <xsl:param name="body.font.master">10</xsl:param>
   <xsl:param name="body.font.family">Arial</xsl:param>
   <xsl:param name="title.font.family">Arial</xsl:param>
   <xsl:param name="symbol.font.family">FreeSans</xsl:param>

   <xsl:attribute-set name="footer.content.properties">
      <xsl:attribute name="font-size">10pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="header.content.properties">
      <xsl:attribute name="font-size">10pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="section.title.level1.properties">
      <xsl:attribute name="font-size">14pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="section.title.level2.properties">
      <xsl:attribute name="font-size">12pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="section.title.level3.properties">
      <xsl:attribute name="font-size">11pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="section.title.level4.properties">
      <xsl:attribute name="font-size">10pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="component.title.properties">
      <xsl:attribute name="font-size">10pt</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="olink.properties">
      <xsl:attribute name="text-decoration">underline</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="xref.properties">
      <xsl:attribute name="color">blue</xsl:attribute>
      <xsl:attribute name="text-decoration">underline</xsl:attribute>
   </xsl:attribute-set>
   
   <!-- Enable graphics for admonitions (warning, caution, note, tip) -->
   <xsl:param name="admon.graphics" select="1"/>
   <xsl:param name="admon.graphics.path"
      >docbook-xsl-1.79.2/images/</xsl:param>
   <xsl:param name="admon.graphics.extension">.svg</xsl:param>

   <!-- Center alignment for Figure Titles -->
   <xsl:attribute-set name="formal.title.properties" use-attribute-sets="normal.para.spacing">
      <xsl:attribute name="text-align">
         <xsl:choose>
            <xsl:when test="self::d:figure and descendant::d:title">center</xsl:when>
            <!--  Also align table titles -->
            <xsl:otherwise>start</xsl:otherwise>
            <!-- default value for alignment-->
         </xsl:choose>
      </xsl:attribute>
   </xsl:attribute-set>

   <!-- Customization to increment table numbering from 1 to n, regardless of section number. 
        Default table numbering is done respective of the number of the section that it is in.-->
   <xsl:template match="d:table | d:figure" mode="label.markup">
      <xsl:choose>
         <xsl:when test="@label">
            <xsl:value-of select="@label"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:number format="1" from="d:book | d:article" level="any"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>


   <!--Table header row customization. Changes all table headers to adhere to the ODNI color 
        standards of bolded white text on the specified RGB value.-->
   <xsl:template name="table.row.properties">
      <xsl:if test="./parent::d:thead">
         <xsl:attribute name="font-weight">bold</xsl:attribute>
         <xsl:attribute name="color">White</xsl:attribute>
         <xsl:attribute name="background-color">#000077</xsl:attribute>
      </xsl:if>
   </xsl:template>
   
   
   <!-- ******************************* -->
   <!--    Title Page Customizations    -->
   <!-- ******************************* -->

   <!-- Override the default abstract behavior to add a rule line before and after -->
   <xsl:template match="d:abstract" mode="titlepage.mode">
      <fo:block padding-before="2em"><fo:leader leader-length="100%" leader-pattern="rule"/></fo:block>
      <fo:block xsl:use-attribute-sets="abstract.properties">
         <fo:block xsl:use-attribute-sets="abstract.title.properties">
            <xsl:choose>
               <xsl:when test="d:title|d:info/d:title">
                  <xsl:apply-templates select="d:title|d:info/d:title"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:call-template name="gentext">
                     <xsl:with-param name="key" select="'Abstract'"/>
                  </xsl:call-template>
               </xsl:otherwise>
            </xsl:choose>
         </fo:block>
         <xsl:apply-templates select="*[not(self::d:title)]" mode="titlepage.mode"/>
      </fo:block>
      <fo:block padding-after="2em"><fo:leader leader-length="100%" leader-pattern="rule"/></fo:block>
   </xsl:template>
   
   <!-- Override default behavior for legal notice to put it in a block with border -->
   <xsl:template match="d:legalnotice" mode="titlepage.mode">
      
      <xsl:variable name="id">
         <xsl:call-template name="object.id"/>
      </xsl:variable>
      
      <fo:block id="{$id}" border="solid" padding="0.5em">
         <xsl:if test="d:title">
            <xsl:call-template name="formal.object.heading"/>
         </xsl:if>
         <xsl:apply-templates mode="titlepage.mode"/>
      </fo:block>
   </xsl:template>
   
</xsl:stylesheet>
