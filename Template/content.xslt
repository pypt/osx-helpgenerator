<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="UTF-8" method="xml" />
	
	<xsl:template match="/">
		<div id="introbox">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="link">
		<a href="help:anchor='{@tag}' bookID='<!#APPLETITLE#!>'">
			<xsl:apply-templates/>
		</a>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="p">
		<div class="introprimtext">
			<p class="introprimtextlongtext">
				<xsl:apply-templates/>
			</p>
		</div>
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="ol/ul">
		<div class="taskauxlist">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="ol/ul/li">
		<div class="taskauxoption">
		<div class="taskauxbullet">■</div>
		<div class="taskauxcontent">
		<p class="taskauxoptionlongtext">
			<xsl:apply-templates/>
		</p>
		</div>
		</div>
	</xsl:template>

	<xsl:template match="ul">
		<div id="introauxlist">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="ul/li">
		<div class="introauxoption">
		<div class="introauxbullet">■</div>
		<div class="introauxcontent">
		<p class="introauxoptionlongtext">
			<xsl:apply-templates/>
		</p>
		</div>
		</div>
	</xsl:template>
	
	<xsl:template match="ol">
		<xsl:apply-templates/>
		<div style="height: 1px"><xsl:text> </xsl:text></div>
	</xsl:template>
	
	<xsl:template match="ol/li">
		<div class="taskprimtext">
		<div class="taskprimbullet">
		<img class="bullet1">
			<xsl:attribute name="src">../gfx/step_<xsl:number format="1"/>.gif</xsl:attribute>
			<xsl:attribute name="alt">Step <xsl:number format="1"/></xsl:attribute>
		</img>
		</div>
		<div class="taskprimcontent">
		<p class="taskprimtextlongtext">
			<xsl:apply-templates/>
		</p>
		</div>
		</div>
	</xsl:template>
	
	<xsl:template match="taskbox">
		<div id="taskbox">
		<div class="border_top">
			<div class="border_topleft"></div>
			<div class="border_topright"></div>
		</div>
		<div class="border_left">
		<div class="border_right">
			<div class="content">
				<h2><xsl:value-of select="@title" /></h2>
				<xsl:apply-templates/>
			</div>
		</div>
		</div>
		<div class="border_bottom">
			<div class="border_bottomleft"></div>
			<div class="border_bottomright"></div>
		</div>
		</div>
	</xsl:template>

	<xsl:template match="img">
		<img src="{@src}"/>
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
	
	<xsl:template match="u">
		<u><xsl:apply-templates/></u>
		<xsl:text> </xsl:text>
	</xsl:template>
	
</xsl:transform>

