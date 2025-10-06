# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic

DESCRIPTION="C++ library for geometric algorithms and data structures"
HOMEPAGE="https://www.cgal.org/"
SRC_URI="
	https://github.com/CGAL/cgal/tarball/63ad16c49dbfda916a88f91c6b0c6d4d0233de7c -> cgal-6.1-63ad16c.tar.gz
	doc? ( https://github.com/CGAL/cgal/releases/download/v6.1/CGAL-6.1-doc_html.tar.xz -> CGAL-6.1-doc_html.tar.xz )
"

LICENSE="LGPL-3 GPL-3 Boost-1.0"
SLOT="0/13"
KEYWORDS="*"
IUSE="doc"

RDEPEND="
	>=dev-cpp/eigen-3.1
	dev-libs/boost:=
	dev-libs/mpfr:0=
	sys-libs/zlib:=
	x11-libs/libX11:=
	virtual/glu:=
	virtual/opengl:=
	dev-libs/gmp:=[cxx]
"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv CGAL-cgal-* "${S}" || die
	fi
}

src_prepare() {
	cmake-utils_src_prepare
	rm Installation/cmake/modules/FindEigen3.cmake || die
	sed -e '/install(FILES AUTHORS/d' \
		-i CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DCGAL_INSTALL_LIB_DIR="$(get_libdir)"
		-DCGAL_INSTALL_CMAKE_DIR="$(get_libdir)/cmake/${PN}"
	)
	cmake-utils_src_configure
}

src_install() {
	use doc && local HTML_DOCS=( "${WORKDIR}"/doc_html/. )
	cmake-utils_src_install
}