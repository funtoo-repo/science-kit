# Distributed under the terms of the GNU General Public License v2

EAPI=7

FORTRAN_NEEDED=fortran

inherit fortran-2 toolchain-funcs autotools flag-o-matic

DESCRIPTION="General purpose library and format for storing scientific data"
HOMEPAGE="http://www.hdfgroup.org/hdf4.html"
SRC_URI="https://github.com/HDFGroup/hdf4/tarball/76795ec6d8b10b80dccd3d5192d0f9224ddda7d0 -> hdf4-4.3.1-76795ec.tar.gz"

SLOT="0"
LICENSE="NCSA-HDF"
KEYWORDS="*"
IUSE="examples fortran szip static-libs test"
REQUIRED_USE="test? ( szip )"

RDEPEND="
	net-libs/libtirpc
	sys-libs/zlib
	virtual/jpeg:0
	szip? ( virtual/szip )"
DEPEND="${RDEPEND}
	test? ( virtual/szip )"

S="${WORKDIR}/HDFGroup-hdf4-76795ec"

src_prepare() {
	default
	sed -i -e 's/-R/-L/g' config/commence.am || die #rpath
	eautoreconf
	[[ $(tc-getFC) = *gfortran ]] && append-fflags -fno-range-check
}

src_configure() {
	econf \
		--enable-shared \
		--enable-production=gentoo \
		--disable-netcdf \
		$(use_enable fortran) \
		$(use_enable static-libs static) \
		$(use_with szip szlib) \
		CC="$(tc-getCC)"
}

src_install() {
	default

	if ! use static-libs; then
		find "${ED}" -name '*.la' -delete || die
	fi

	dodoc release_notes/{RELEASE,HISTORY,bugs_fixed,misc_docs}.txt
}