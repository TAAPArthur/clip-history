# Maintainer: Arthur Williams <taaparthur@gmail.com>


pkgname='sync-clip'
pkgbase="taapscripts"
pkgver='0.1'
_language='en-US'
pkgrel=4
pkgdesc='Syncrop clipboard across various devices'
install=$pkgname.install
arch=('any')
license=('MIT')
depends=('python3' 'xsel' 'pyinotify-runner')
md5sums=('SKIP')

source=("git://github.com/TAAPArthur/sync-clip.git")
_srcDir="sync-clip"

package() {
    cd "$_srcDir"
    mkdir -p "$pkgdir/usr/bin/"
    mkdir -p "$pkgdir/usr/share/$pkgname"
    install -D -m 0755 sync-clip.py "$pkgdir/usr/bin/sync-clip"
    install -D -m 0755 *.json "$pkgdir/usr/share/$pkgname"
}
