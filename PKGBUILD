# Maintainer: Chase Brown <chase.brown.dev@gmail.com>
pkgname=rthemes
pkgver=1.0
pkgrel=1
pkgdesc="Hyprland + Waybar theme ricing and swapping made easy"
arch=('x86_64')
url="https://github.com/YOUR_USERNAME/rthemes"  # TODO: update before AUR submission
license=('custom')
depends=('hyprland' 'waybar' 'swww')
source=('themeset.sh' 'themes.tar' 'LICENSE.txt')
sha256sums=('03207157967be6e6dfb3d42befdad48c07edfca6c7643ed1f11b6dc265da849d' \
            '5a16053eafc08725e50d31e2d6b48d2d914e7cbf0c760fded7c88203436febfc' \
            '11968ba3b6897b3c1046bebc8f09bda5335f30131757db4e9998ee571ef46fc7')

package() {
    install -Dm755 "$srcdir/themeset.sh" "$pkgdir/usr/bin/themeset"

    mkdir -p "$pkgdir/usr/share/themeset"
    tar -xf "$srcdir/themes.tar" -C "$pkgdir/usr/share/themeset"

    install -Dm644 "$srcdir/LICENSE.txt" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
