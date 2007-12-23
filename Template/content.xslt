<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="UTF-8" method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<div id="introbox">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="link">
		<a href="help:anchor='{@href}' bookID=$$APPLETITLE$$">
			<xsl:apply-templates/>
		</a>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="para">
		<div class="introprimtext">
			<p class="introprimtextlongtext">
				<xsl:apply-templates/>
			</p>
		</div>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="b">
		<b><xsl:apply-templates/></b>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="i">
		<i><xsl:apply-templates/></i>
		<xsl:text> </xsl:text>
	</xsl:template>
	
</xsl:transform>
