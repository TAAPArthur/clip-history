# Maintainer: Arthur Williams <taaparthur@gmail.com>


pkgname='clip-history'
pkgver='0.3'
_language='en-US'
pkgrel=0
pkgdesc='Simply keeps a list of everything copied'
arch=('any')
license=('MIT')
depends=('python3' 'xsel' 'python-gobject')
md5sums=('SKIP')

source=("git+https://github.com/TAAPArthur/clip-history.git")
_srcDir="clip-history"

package() {
    cd "$_srcDir"
    install -D -m 0755 clip-history.sh "$pkgdir/usr/bin/clip-history"
}
