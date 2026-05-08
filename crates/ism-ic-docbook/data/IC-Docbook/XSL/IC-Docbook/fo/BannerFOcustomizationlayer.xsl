<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xl="http://www.w3.org/1999/xlink"
   xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
   xmlns:ism="urn:us:gov:ic:ism" xmlns:d="http://docbook.org/ns/docbook" xmlns:s="urn:us:gov:ic:specteam" version="1.0">

   <!-- This customization layer aims to modify the generated output of the 
        default docbook xsl FO transform, and thus the output of FOP ODF output.
        
        Simple customizations with self-explanatory parameter names and attribute 
        sets are typically grouped together with a simple comment description of the group.
        
        For more complex customizations that typically replace template matches in the 
        default docbook xsl, comments that describe what the change is, how the change 
        was made, and why the change was made, are placed above the blocks of code that 
        have been modified.
    -->
   
   <!--Indicates the location of the default docbook XSL.  Change if needed-->
   <xsl:import href="../docbook-xsl-1.79.2/fo/docbook.xsl"/>
   
   <!-- Pull in the ISM rendering stylesheets to generate banner text -->
   <xsl:import href="../../ISM/IC-ISM-SecurityBanner.xsl"/>
   

   <!--Indentation makes troubleshooting the FO much easier ;) -->
   <!--Indentation breaks the syntax highlighting of the code. Leave off unless debugging -->
   <xsl:output method="xml" encoding="UTF-8" indent="no"/>


   <!-- Is this copy a draft? -->
   <xsl:param name="isDraft" select="$draft.mode"/>

   <!-- enable mailto elements to render as links. -->
   <xsl:param name="email.mailto.enabled" select="1"/>

   <!-- <xsl:param name="bibliography.style" select="iso690"/>  -->
   <xsl:param name="bibliography.numbered" select="1"/>

   <!--Puts figure titles below the figure, and table titles above the table-->
   <xsl:param name="formal.title.placement"> figure after table before </xsl:param>
   
   <!--Specifies the column ratios for headers and footers to allow for classification-->
   <xsl:param name="header.column.widths">1 1 1</xsl:param>
   <xsl:param name="footer.column.widths">1 10 1</xsl:param>
   
   <xsl:variable name="BannerText">
      <xsl:choose>
         <xsl:when test="/d:*[@ism:*]">
            <xsl:apply-templates select="/d:*" mode="ism:banner"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="/*/d:info/d:releaseinfo[@role='usa.nsi.banner']"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   
   <xsl:variable name="declassBlock">
      <xsl:choose>
         <xsl:when test="/d:*[@ism:*]">
            <xsl:apply-templates select="/d:*[@ism:*]" mode="ism:authority"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="/*/d:info/d:releaseinfo[@role='usa.nsi.block']"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>

   <!--Customizations to the document header. Adds location specific information
        (classification, DES name, and signature date) to the header. Limits header 
        information placed on the header to classification. -->
   <xsl:template name="header.content">
      <xsl:param name="pageclass" select="''"/>
      <xsl:param name="sequence" select="''"/>
      <xsl:param name="position" select="''"/>
      <xsl:param name="gentext-key" select="''"/>
      <fo:block>
         <xsl:choose>
            <xsl:when test="$position = 'center'">
               <fo:block width="1600pt" font-size="12pt" font-family="Courier">
                  <xsl:value-of select="$BannerText"/>
               </fo:block>
            </xsl:when>
            <xsl:when test="$position = 'left' and not($pageclass = 'titlepage')">
               <xsl:apply-templates select="/*/d:info/d:title[1]/text() | /*/d:info/d:title[1]/*"/>
            </xsl:when>
            <xsl:when test="$position = 'right' and not($pageclass = 'titlepage') and $draft.mode = 'yes'">
               <xsl:apply-templates select="//d:pubdate[1][not(child::*)]/text() |//d:pubdate[1]/*"/>
            </xsl:when>
            <xsl:when test="$position = 'right' and not($pageclass = 'titlepage') and $draft.mode = 'no'">
               <xsl:apply-templates select="//d:date[position()=1 and not(child::*)]/text() |//d:date[1]/*"/>
            </xsl:when>
            <xsl:when test="$pageclass = 'titlepage'">
               <!-- Do nothing -->
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>Oops we should not see this pageclass:"</xsl:text>
               <xsl:value-of select="$pageclass"/>
               <xsl:text>" $draft.mode:"</xsl:text>
               <xsl:value-of select="$draft.mode"/>
               <xsl:text>"</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </fo:block>
   </xsl:template>

   <!--Customizations to the document footer. Adds location specific information
        (classification and page number) to the footer. Limits footer information 
        placed on the header to classification. -->
   <xsl:template name="footer.content">
      <xsl:param name="pageclass" select="''"/>
      <xsl:param name="sequence" select="''"/>
      <xsl:param name="position" select="''"/>
      <xsl:param name="gentext-key" select="''"/>
      <fo:block width="100%">
         <xsl:choose>
            <xsl:when test="$position = 'center'">
               <xsl:if test="($pageclass='titlepage' and $sequence='first') or ($gentext-key='article' and $sequence='first')">
                  <xsl:variable name="declassBlockList">
                     <xsl:call-template name="tokenizeString">
                        <xsl:with-param name="list" select="/*/d:info/d:releaseinfo[@role='usa.nsi.block']"/>
                        <xsl:with-param name="delimiter" select="'|'"/>
                     </xsl:call-template>
                  </xsl:variable>
                  <fo:block margin-bottom="2em">
                    <xsl:for-each select="$declassBlockList/item">
                       <fo:block width="100%" text-align="left" font-size="12pt" font-family="Courier"><xsl:value-of select="."/></fo:block>
                    </xsl:for-each>
                  </fo:block>
               </xsl:if>
               <fo:block width="100%">
                  <xsl:value-of select="/*/d:info/d:releaseinfo[@role='footer.notice']"/>
               </fo:block>
               <fo:block width="100%" font-size="12pt" font-family="Courier">
                  <xsl:value-of select="$BannerText"/>
               </fo:block>
            </xsl:when>
            <xsl:when test="$position = 'right' and not($pageclass = 'titlepage')">
               <fo:page-number/>
            </xsl:when>
         </xsl:choose>
      </fo:block>
   </xsl:template>
   
   <!--Customizations to the header generation template.disables separators on the titlepage -->
   <xsl:template name="header.table">
      <xsl:param name="pageclass" select="''"/>
      <xsl:param name="sequence" select="''"/>
      <xsl:param name="gentext-key" select="''"/>
      
      <!-- default is a single table style for all headers -->
      <!-- Customize it for different page classes or sequence location -->
      
      <xsl:choose>
         <xsl:when test="$pageclass = 'index'">
            <xsl:attribute name="margin-{$direction.align.start}">0pt</xsl:attribute>
         </xsl:when>
      </xsl:choose>
      
      <xsl:variable name="column1">
         <xsl:choose>
            <xsl:when test="$double.sided = 0">1</xsl:when>
            <xsl:when test="$sequence = 'first' or $sequence = 'odd'">1</xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="column3">
         <xsl:choose>
            <xsl:when test="$double.sided = 0">3</xsl:when>
            <xsl:when test="$sequence = 'first' or $sequence = 'odd'">3</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="candidate">
         <fo:table xsl:use-attribute-sets="header.table.properties">
            
            <!--Disables the separating line between the body of the text and the 
                    header on the titlepage-->
            <xsl:choose>
               <xsl:when test="$pageclass != 'titlepage'">
                  <xsl:call-template name="head.sep.rule">
                     <xsl:with-param name="pageclass" select="$pageclass"/>
                     <xsl:with-param name="sequence" select="$sequence"/>
                     <xsl:with-param name="gentext-key" select="$gentext-key"/>
                  </xsl:call-template>
               </xsl:when>
            </xsl:choose>
            
            <fo:table-column column-number="1"/>
            <fo:table-column column-number="2"/>
            <fo:table-column column-number="3"/>
            
            
            <fo:table-body>
               <fo:table-row font-size="12pt" font-family="Courier">
                  <fo:table-cell number-columns-spanned="3" text-align="center" display-align="before">
                     <xsl:call-template name="header.content">
                        <xsl:with-param name="pageclass" select="$pageclass"/>
                        <xsl:with-param name="sequence" select="$sequence"/>
                        <xsl:with-param name="position" select="'center'"/>
                        <xsl:with-param name="gentext-key" select="$gentext-key"/>
                     </xsl:call-template>
                  </fo:table-cell>
               </fo:table-row>
               
               <fo:table-row>
                  <fo:table-cell number-columns-spanned="2" text-align="start" display-align="before">
                     <xsl:call-template name="header.content">
                        <xsl:with-param name="pageclass" select="$pageclass"/>
                        <xsl:with-param name="sequence" select="$sequence"/>
                        <xsl:with-param name="position" select="$direction.align.start"/>
                        <xsl:with-param name="gentext-key" select="$gentext-key"/>
                     </xsl:call-template>
                  </fo:table-cell>
                  <fo:table-cell text-align="right" display-align="before">
                     <xsl:call-template name="header.content">
                        <xsl:with-param name="pageclass" select="$pageclass"/>
                        <xsl:with-param name="sequence" select="$sequence"/>
                        <xsl:with-param name="position" select="$direction.align.end"/>
                        <xsl:with-param name="gentext-key" select="$gentext-key"/>
                     </xsl:call-template>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-body>
         </fo:table>
      </xsl:variable>
      
      <!--Enables the header on the titlepage.  By default, the title page has no header, 
            but here the check is removed so that banner markings can be displayed.-->
      <xsl:choose>
         <!--      <xsl:when test="$pageclass = 'titlepage' and $gentext-key = 'book'
                and $sequence='first'">
                <!-\- no, book titlepages have no headers at all -\->
                </xsl:when>-->
         <xsl:when test="$sequence = 'blank' and $headers.on.blank.pages = 0">
            <!-- no output -->
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="$candidate"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!--Customizations to the footer generation template. -->
   <xsl:template name="footer.table">
      <xsl:param name="pageclass" select="''"/>
      <xsl:param name="sequence" select="''"/>
      <xsl:param name="gentext-key" select="''"/>
      
      <!-- default is a single table style for all footers -->
      <!-- Customize it for different page classes or sequence location -->
      
      <xsl:choose>
         <xsl:when test="$pageclass = 'index'">
            <xsl:attribute name="margin-{$direction.align.start}">0pt</xsl:attribute>
         </xsl:when>
      </xsl:choose>
      
      <xsl:variable name="column1">
         <xsl:choose>
            <xsl:when test="$double.sided = 0">1</xsl:when>
            <xsl:when test="$sequence = 'first' or $sequence = 'odd'">1</xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="column3">
         <xsl:choose>
            <xsl:when test="$double.sided = 0">3</xsl:when>
            <xsl:when test="$sequence = 'first' or $sequence = 'odd'">3</xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:variable name="candidate">
         <fo:table xsl:use-attribute-sets="footer.table.properties">
            
            <!--Disables the separating line between the body of the text and the 
                    footer on the titlepage-->
            <xsl:choose>
               <xsl:when test="$pageclass != 'titlepage'">
                  <xsl:call-template name="foot.sep.rule">
                     <xsl:with-param name="pageclass" select="$pageclass"/>
                     <xsl:with-param name="sequence" select="$sequence"/>
                     <xsl:with-param name="gentext-key" select="$gentext-key"/>
                  </xsl:call-template>
               </xsl:when>
            </xsl:choose>
            
            <fo:table-column column-number="1">
               <xsl:attribute name="column-width">
                  <xsl:text>proportional-column-width(</xsl:text>
                  <xsl:call-template name="header.footer.width">
                     <xsl:with-param name="location">footer</xsl:with-param>
                     <xsl:with-param name="position" select="$column1"/>
                  </xsl:call-template>
                  <xsl:text>)</xsl:text>
               </xsl:attribute>
            </fo:table-column>
            <fo:table-column column-number="2">
               <xsl:attribute name="column-width">
                  <xsl:text>proportional-column-width(</xsl:text>
                  <xsl:call-template name="header.footer.width">
                     <xsl:with-param name="location">footer</xsl:with-param>
                     <xsl:with-param name="position" select="2"/>
                  </xsl:call-template>
                  <xsl:text>)</xsl:text>
               </xsl:attribute>
            </fo:table-column>
            <fo:table-column column-number="3">
               <xsl:attribute name="column-width">
                  <xsl:text>proportional-column-width(</xsl:text>
                  <xsl:call-template name="header.footer.width">
                     <xsl:with-param name="location">footer</xsl:with-param>
                     <xsl:with-param name="position" select="$column3"/>
                  </xsl:call-template>
                  <xsl:text>)</xsl:text>
               </xsl:attribute>
            </fo:table-column>
            
            <fo:table-body>
               <fo:table-row>
                  <xsl:attribute name="block-progression-dimension.minimum">
                     <xsl:value-of select="$footer.table.height"/>
                  </xsl:attribute>
                  <fo:table-cell text-align="start" display-align="after">
                     <xsl:if test="$fop.extensions = 0">
                        <xsl:attribute name="relative-align">baseline</xsl:attribute>
                     </xsl:if>
                     <fo:block>
                        <xsl:call-template name="footer.content">
                           <xsl:with-param name="pageclass" select="$pageclass"/>
                           <xsl:with-param name="sequence" select="$sequence"/>
                           <xsl:with-param name="position" select="$direction.align.start"/>
                           <xsl:with-param name="gentext-key" select="$gentext-key"/>
                        </xsl:call-template>
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell text-align="center" display-align="after">
                     <xsl:if test="$fop.extensions = 0">
                        <xsl:attribute name="relative-align">baseline</xsl:attribute>
                     </xsl:if>
                     <fo:block>
                        <xsl:call-template name="footer.content">
                           <xsl:with-param name="pageclass" select="$pageclass"/>
                           <xsl:with-param name="sequence" select="$sequence"/>
                           <xsl:with-param name="position" select="'center'"/>
                           <xsl:with-param name="gentext-key" select="$gentext-key"/>
                        </xsl:call-template>
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell text-align="end" display-align="after">
                     <xsl:if test="$fop.extensions = 0">
                        <xsl:attribute name="relative-align">baseline</xsl:attribute>
                     </xsl:if>
                     <fo:block>
                        <xsl:call-template name="footer.content">
                           <xsl:with-param name="pageclass" select="$pageclass"/>
                           <xsl:with-param name="sequence" select="$sequence"/>
                           <xsl:with-param name="position" select="$direction.align.end"/>
                           <xsl:with-param name="gentext-key" select="$gentext-key"/>
                        </xsl:call-template>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-body>
         </fo:table>
      </xsl:variable>
      
      <!--Enables the footer on the titlepage.  By default, the title page has no footer, 
            but here the check is removed so that banner markings can be displayed.-->
      <xsl:choose>
             <!--<xsl:when test="$pageclass='titlepage' and $gentext-key = 'book'
                and $sequence='first'">
                <!-\- no, book titlepages have no footers at all -\->
             </xsl:when>-->
         <xsl:when test="$sequence = 'blank' and $footers.on.blank.pages = 0">
            <!-- no output -->
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="$candidate"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   
   <xsl:template name="tokenizeString">
      <!--passed template parameter -->
      <xsl:param name="list"/>
      <xsl:param name="delimiter"/>
      <xsl:choose>
         <xsl:when test="contains($list, $delimiter)">          
            <item>
               <!-- get everything in front of the first delimiter -->
               <xsl:value-of select="substring-before($list,$delimiter)"/>
            </item>
            <xsl:call-template name="tokenizeString">
               <!-- store anything left in another variable -->
               <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
               <xsl:with-param name="delimiter" select="$delimiter"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$list = ''">
                  <xsl:text/>
               </xsl:when>
               <xsl:otherwise>
                  <item>
                     <xsl:value-of select="$list"/>
                  </item>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>  
   
</xsl:stylesheet>
