# Maintainer: Arthur Williams <taaparthur@gmail.com>


pkgname='clip-history'
pkgver='0.4'
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
    install -D -m 0755 clip-history-autocomplete.sh "$pkgdir/etc/bash_completion.d/clip-history-autocomplete"
    install -m 0744 -Dt "$pkgdir/usr/share/man/man1/" clip-history.1
}
