<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove unsupported IDE controller on ARM/QEMU virt machine -->
  <xsl:template match="controller[@type='ide']"/>

  <!-- Change cloud-init CD-ROM from IDE to SCSI -->
  <xsl:template match="disk[@device='cdrom']/target">
    <target dev="sdc" bus="scsi"/>
  </xsl:template>

  <!-- Remove old IDE address from CD-ROM if present -->
  <xsl:template match="disk[@device='cdrom']/address"/>

</xsl:stylesheet>
