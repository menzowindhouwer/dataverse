<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:js="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs xsi js"
    version="3.0">  
    
    <xsl:template match="text()"/>
    
    <xsl:variable name="profs" as="node()*">
        <!--<prof block="citation" root="citationProfile" id="clarin.eu:cr1:p_1639731773881"/>-->
        <xsl:sequence select="document(environment-variable('DV_CMDI_CONF'))//prof"/>
    </xsl:variable>
    
    <xsl:template match="js:map[@key='metadataBlocks']">
        <xsl:variable name="block" select="js:map/@key"/>
        <xsl:variable name="root" select="$profs[@block=$block]/@root"/>
        <xsl:variable name="prof" select="$profs[@block=$block]/@id"/>
        <xsl:variable name="ns" select="concat('http://www.clarin.eu/cmd/1/profiles/',$prof)"/>
        <cmd:CMD  xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://infra.clarin.eu/CMDI/1.x/xsd/cmd-envelop.xsd http://www.clarin.eu/cmd/1/profiles/{$prof} https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/{$prof}/xsd" CMDVersion="1.2">
            <xsl:namespace name="cmdp" select="$ns"/>                    
            <cmd:Header>
                <cmd:MdCreator>
                    <xsl:value-of select="/js:map/js:string[@key='publisher']"/>
                </cmd:MdCreator>
                <cmd:MdCreationDate>
                    <xsl:value-of select="/js:map/js:string[@key='publicationDate']"/>
                </cmd:MdCreationDate>
                <cmd:MdSelfLink>
                    <xsl:value-of select="/js:map/js:string[@key='persistentUrl']"/>
                </cmd:MdSelfLink>
                <cmd:MdProfile xsl:expand-text="yes">{$prof}</cmd:MdProfile>
            </cmd:Header>
            <cmd:Resources>
                <cmd:ResourceProxyList>
                    <cmd:ResourceProxy id="lp">
                        <cmd:ResourceType mimetype="text/html">LandingPage</cmd:ResourceType>
                        <cmd:ResourceRef>
                            <xsl:variable name="base" select="js:system-property('dataverse.siteUrl')"/>
                            <xsl:value-of select="$base"/>
                            <xsl:if test="not(ends-with($base,'/'))">
                                <xsl:text>/</xsl:text>
                            </xsl:if>
                            <xsl:text>dataset.xhtml?persistentId=</xsl:text>
                            <xsl:value-of select="replace(/js:map/js:string[@key='persistentUrl'],'https://doi.org/','doi:')"/>
                        </cmd:ResourceRef>
                    </cmd:ResourceProxy>
                    <xsl:for-each select="/js:map/js:map/js:array[@key='files']/js:map">
                        <cmd:ResourceProxy id="r{position()}">
                            <cmd:ResourceType mimetype="{.//js:string[@key='contentType']}">Resource</cmd:ResourceType>
                            <cmd:ResourceRef>
                                <xsl:choose>
                                    <xsl:when test="normalize-space(.//js:string[@key='pidURL'])!=''">
                                        <xsl:value-of select="normalize-space(.//js:string[@key='pidURL'])"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text expand-text="yes">{.//js:string[@key='storageIdentifier']}/{.//js:string[@key='filename']}</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose></cmd:ResourceRef>
                        </cmd:ResourceProxy>                        
                    </xsl:for-each>
                </cmd:ResourceProxyList>
                <cmd:JournalFileProxyList/>
                <cmd:ResourceRelationList/>
            </cmd:Resources>
            <cmd:Components>
                <xsl:element name="cmdp:{$root}" namespace="{$ns}">
                    <xsl:apply-templates select="js:map[@key=$block]/js:array[@key='fields']/*">
                        <xsl:with-param name="ns" select="$ns" tunnel="yes"></xsl:with-param>
                    </xsl:apply-templates>
                </xsl:element>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>
    
    <xsl:template match="js:map[exists(*[@key='value'])][exists(js:string[@key='typeName'])]">
        <xsl:param name="ns" tunnel="yes"/>
        <xsl:variable name="name" select="./js:string[@key='typeName']"/>
        <xsl:choose>
            <xsl:when test="exists(js:string[@key='value'])">
                <xsl:element name="cmdp:{$name}" namespace="{$ns}" expand-text="yes">{./js:string[@key='value']}</xsl:element>                
            </xsl:when>
            <xsl:when test="exists(js:array[@key='value']/js:string)">
                <xsl:for-each select="js:array[@key='value']/js:string">
                    <xsl:element name="cmdp:{$name}" namespace="{$ns}" expand-text="yes">{.}</xsl:element>                
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="exists(js:array[@key='value']/js:map)">
                <xsl:element name="cmdp:{$name}" namespace="{$ns}">
                    <xsl:apply-templates select="js:array[@key='value']/*">
                        <xsl:with-param name="ns" select="$ns" tunnel="yes"></xsl:with-param>
                    </xsl:apply-templates>
                </xsl:element>                
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>