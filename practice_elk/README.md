# Elk

オープンソースの全電子計算ソフトウェアです。

## インストール

以下の環境におけるインストール手順です。

- Rocky9
- oneAPI

## Libxcのコンパイル

Elkを使う動機の一つに、様々な交換相関汎函数を利用することが挙げられます。
その実現のために[Libxc](https://libxc.gitlab.io/)を利用します。

[公式サイト](https://libxc.gitlab.io/download/)から最新版ソースコード一式をダウンロードします。
執筆時点の最新版は7.0.0です。
<!-- セキュリティ設定の問題からか、ブラウザやウィルス対策ソフトウェアの組み合わせによってはダウンロードできない場合があるようです。 -->
<!-- ダウンロードできない場合は、ブラウザを変えるなどお試しください。 -->

Linuxの標準的な手順でインストールします。
`aclocal`コマンドがない場合は、`libtool`を追加インストールしてください。
oneAPIを利用する場合は、Cコンパイラのコマンドを指定します（`CC=icx FC=ifx`）。
インストール先は、ホームディレクトリ直下の`local`としてみます。

```sh
tar xf libxc-7.0.0.tar.gz
cd libxc-7.0.0
aclocal
autoreconf -f -i
./configure CC=icx FC=ifx --prefix=$HOME/local
make install
```

`$HOME/local/lib`ディレクトリに、ライブラリが生成されています。

```sh
$ ls $HOME/local/lib
libxc.a  libxcf03.a  libxcf03.la  libxcf90.a  libxcf90.la  libxc.la  pkgconfig
```

## Elkのコンパイル

続けてElk本体をコンパイルします。

[公式サイト](https://elk.sourceforge.io/)からソースコードをダウンロードします。
執筆時点の最新版は10.2.4です。

```sh
tar xf elk-10.2.4.tgz
cd elk-10.2.4
```

`make.inc`を編集します。
まずコンパイラに関して、Intel Fortran compiler classic (ifort)を使う場合は変更しません。
最新のoneAPI（LLVM-based compiler; ifx）を利用する場合は、以下の様に行先頭の`#`を消去してください。

```makefile
# Intel Fortran LLVM-based compiler (ifx).
F90 = mpiifx
F90_OPTS = -O3 -xHost -ipo -qopenmp -qmkl=parallel
F90_LIB = -liomp5 -lpthread -lm -ldl
SRC_MKL =
AR = xiar
```

（oneAPI 2025では、ifortが廃止されました。）

次に、Libxcを有効にするために、以下の様に行先頭`#`を消去してください。

```makefile
LIB_LIBXC = libxcf03.a libxc.a
SRC_LIBXC = libxcf03.f90 libxcifc.f90
```


インストール済みLibxcから、`$HOME/local/lib`にある`libxcf03.a`と`libxc.a`の二つを、Elkの`src`ディレクトリにコピーします。

```sh
cp $HOME/local/lib/libxcf03.a src
cp $HOME/local/lib/libxc.a src
```

以上で準備が整いました。
`make`コマンドでコンパイルします。

```sh
make
```

`src`ディレクトリに`elk`コマンドが生成されていることを確認してください。

```sh
$ ls src/elk
src/elk
```
