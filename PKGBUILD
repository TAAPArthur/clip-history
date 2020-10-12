# Maintainer: Arthur Williams <taaparthur at gmail dot com>


pkgname='clip-history'
pkgver='0.8'
_language='en-US'
pkgrel=0
pkgdesc='A clipboard manager that simply keeps a list of everything copied'
arch=('any')
license=('MIT')
depends=('xclip')
md5sums=('SKIP')

source=("git+https://github.com/TAAPArthur/clip-history.git")
_srcDir="clip-history"

package() {
    cd "$_srcDir"
    make DESTDIR=$pkgdir install
}
