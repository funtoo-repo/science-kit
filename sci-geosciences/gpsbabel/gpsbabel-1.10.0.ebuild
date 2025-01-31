EAPI=7

inherit cmake

MY_PV="${PV//./_}"
MY_P="${PN}_${MY_PV}"

DESCRIPTION="GPS waypoints, tracks and routes converter"
HOMEPAGE="https://www.gpsbabel.org/ https://github.com/GPSBabel/gpsbabel"
SRC_URI="https://api.github.com/repos/GPSBabel/gpsbabel/tarball/refs/tags/gpsbabel_1_10_0 -> gpsbabel-1.10.0.tar.gz
    doc? ( https://www.gpsbabel.org/style3.css -> gpsbabel.org-style3.css )
"
KEYWORDS="*"

LICENSE="GPL-2"
SLOT="0"
IUSE="doc"

DEPEND="
	dev-qt/qtcore:5
	sci-libs/shapelib:=
	sys-libs/zlib
	virtual/libusb:1
"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.1.2
		dev-lang/perl
		dev-libs/libxslt
	)
"
RDEPEND="${DEPEND}"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv GPSBabel-* "${S}" || die
	fi
}
src_prepare() {
	# ensure bundled libs are not used
	rm -r shapelib zlib || die
	cmake_src_prepare
	use doc && cp "${DISTDIR}/gpsbabel.org-style3.css" "${S}"
}

src_configure() {
local mycmakeargs=(
 -DGPSBABEL_MAPPREVIEW=OFF # Avoid bringing in Python 2.x QtWebEngineWidgets
 -DGPSBABEL_WITH_SHAPELIB=pkgconfig # Use system libs, not bundled libs
 -DGPSBABEL_WITH_ZLIB=pkgconfig # Use system libs, not bundled libs
)
cmake_src_configure
}


src_compile() {
	cmake_src_compile

	if use doc; then
	perl xmldoc/makedoc
		xsltproc \
		--output gpsbabel.html \
		--stringparam toc.section.depth "1" \
		--stringparam html.cleanup "1" \
		--stringparam make.clean.html "1" \
		--stringparam html.valid.html "1" \
		--stringparam html.stylesheet "https://www.gpsbabel.org/style3.css" \
		http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl \
		xmldoc/readme.xml
	fi
}

src_install() {
	local installdir="/usr/bin"
	local builddir="${S}_build"
	exeinto ${installdir}
	doexe "${builddir}/gpsbabel"
	use doc && dodoc ${PN}.html ${PN}.org-style3.css
}