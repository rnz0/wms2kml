<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (c) 2009 Earth Data Analysis Center

    Karl Benedict <kbene@edac.unm.edu>
    Renzo Sanchez-Silva <renzo@edac.unm.edu>

    This file is part of ESIP-EDAC WMS to KML converter.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program  is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />
    <xsl:param name='baseurl'/>
    <xsl:param name='format'/>
    <xsl:template match="/">
		<xsl:variable name='baseurlprev' select="WMT_MS_Capabilities/Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource/@*[name()='xlink:href']"/>
		<xsl:variable name='formatprev' select="WMT_MS_Capabilities/Capability/Request/GetMap/Format"/>

		<xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
		<xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable> 

        <xsl:apply-templates select="WMT_MS_Capabilities">
			<xsl:with-param name='version' select="WMT_MS_Capabilities/@version"/>
			<xsl:with-param name='baseurl'>
				<xsl:choose>
					<xsl:when test="contains($baseurlprev,'?')"><xsl:value-of select="$baseurlprev"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$baseurlprev"/>?</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name='format'>
				<xsl:choose>
					<xsl:when test="$formatprev[translate(text(),$upper,$lower)='image/png']">image/png</xsl:when>
					<xsl:when test="$formatprev[translate(text(),$upper,$lower)='image/gif']">image/gif</xsl:when>
					<xsl:when test="$formatprev[translate(text(),$upper,$lower)='image/jpg']">image/jpg</xsl:when>
					<xsl:otherwise>image/png</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
    </xsl:template>
    <xsl:template match="WMT_MS_Capabilities">
		<xsl:param name="version"/>
		<xsl:param name="baseurl"/>
		<xsl:param name="format"/>
		<kml xmlns="http://earth.google.com/kml/2.2">
            <xsl:apply-templates select="Service">
				<xsl:with-param name='version' select="$version"/>
				<xsl:with-param name='baseurl' select="$baseurl"/>
				<xsl:with-param name='format' select="$format"/>
			</xsl:apply-templates>
        </kml>
    </xsl:template>
	<xsl:template match="Service">
		<xsl:param name="version"/>
		<xsl:param name="baseurl"/>
		<xsl:param name="format"/>
		<Folder>
			<name>
				<xsl:value-of select="Title"/>
			</name>
			<visibility/>
			<description>
				<xsl:value-of select="Abstract"/>
			</description>
			<LookAt>
				<longitude>	
					<xsl:value-of select="//Layer/LatLonBoundingBox/@minx div 2 + //Layer/LatLonBoundingBox/@maxx div 2"/>
				</longitude>
				<latitude>
					<xsl:value-of select="//Layer/LatLonBoundingBox/@miny div 2 + //Layer/LatLonBoundingBox/@maxy div 2"/>
				</latitude>
				<altitude>0</altitude>
				<range>1000000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
		    <Style>
				<ListStyle>
					<listItemType>check</listItemType>
					<bgColor>00ffffff</bgColor>
					<maxSnippetLines>2</maxSnippetLines>
				</ListStyle>
			</Style>
			<!-- Loop over layers here -->
			<xsl:for-each select="//Layer/Layer">
		   <GroundOverlay>
				<xsl:variable name='name' select='Name'/>
				<name><xsl:value-of select="Title"/></name>
				<visibility>0</visibility>
				<snippet></snippet>
				<Snippet maxLines="0"></Snippet>
				<description>
					<xsl:value-of select="Abstract"/>
					<xsl:value-of select="MetadataURL/OnlineResource/@href"/>
				</description>
				<LookAt>
					<longitude>	
						<xsl:value-of select="LatLonBoundingBox/@minx div 2 +LatLonBoundingBox/@maxx div 2"/>
					</longitude>
					<latitude>
						<xsl:value-of select="LatLonBoundingBox/@miny div 2 + LatLonBoundingBox/@maxy div 2"/>
					</latitude>
					<altitude>0</altitude>
					<range>1000000</range>
					<tilt>0</tilt>
					<heading>0</heading>
				</LookAt>
				<drawOrder>2</drawOrder>
				<xsl:if test="$baseurl">
					<xsl:if test="$format">
						<Icon>
							<href><xsl:value-of select='$baseurl'/>VERSION=<xsl:value-of select='$version'/>&amp;REQUEST=GetMap&amp;SRS=EPSG:4326&amp;WIDTH=1024&amp;HEIGHT=1024&amp;LAYERS=<xsl:value-of select="$name"/>&amp;TRANSPARENT=TRUE&amp;FORMAT=<xsl:value-of select="$format"/></href>
							<viewRefreshMode>onStop</viewRefreshMode>
						</Icon>
					</xsl:if>
				</xsl:if>
				<LatLonBox>
					<north>
						<xsl:value-of select="LatLonBoundingBox/@maxy"/>
					</north>
					<south>
						<xsl:value-of select="LatLonBoundingBox/@miny"/>
					</south>
					<east>
						<xsl:value-of select="LatLonBoundingBox/@maxx"/>
					</east>
					<west>
						<xsl:value-of select="LatLonBoundingBox/@minx"/>
					</west>
				</LatLonBox>
			</GroundOverlay>
			</xsl:for-each>
		</Folder>
	</xsl:template>
</xsl:stylesheet>
