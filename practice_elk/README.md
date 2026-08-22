# Elk

オープンソースの全電子計算ソフトウェアです。

## インストール

以下の環境におけるインストール手順です。

- Rocky10
- oneAPI

## Libxcのコンパイル

Elkを使う動機の一つに、様々な交換相関汎函数を利用することが挙げられます。
その実現のために[Libxc](https://libxc.gitlab.io/)を利用します。

[公式サイト](https://libxc.gitlab.io/download/)から最新版ソースコード一式をダウンロードします。
執筆時点の最新版は7.1.2です。

Linuxの標準的な手順でインストールします。
`aclocal`コマンドがない場合は、`libtool`を追加インストールしてください。
oneAPIを利用する場合は、Cコンパイラのコマンドを指定します（`CC=icx FC=ifx`）。
インストール先は、ホームディレクトリ直下の`local`としてみます。

```sh
tar xf libxc-7.1.2.tar.gz
cd libxc-7.1.2
aclocal
autoreconf -f -i
./configure CC=icx FC=ifx --prefix=$HOME/local --enable-static
make install
```

`$HOME/local/lib`ディレクトリに、ライブラリが生成されています。

```sh
$ ls $HOME/local/lib
libxc.a  libxcf03.a  ...
```

## Elkのコンパイル

続けてElk本体をコンパイルします。

[公式サイト](https://elk.sourceforge.io/)からソースコードをダウンロードします。
執筆時点の最新版は11.0.2です。

```sh
tar xf elk-11.0.2.tgz
cd elk-11.0.2
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

（oneAPI 2025から、ifortは廃止されています。）

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

（前者は無くても動作します；使わない場合は、`make.inc`の`LIB_LIBXC`から削除します。）

Elk 11.0.2リリース時点でのlibxc最新版は7.0.0でした。
そのままでは、libxc 7.1.2は使えないので、ELKのソースコードを以下のように修正します。

```diff
--- libxcf03.f90.org    2026-08-21 16:10:10.534636330 +0900
+++ libxcf03.f90        2026-08-21 16:10:50.487787371 +0900
@@ -296,7 +296,7 @@ module xc_f03_lib_m
       type(c_ptr), value :: p
     end subroutine xc_func_free

-    subroutine libxc_free(p) bind(c)
+    subroutine libxc_free(p) bind(c, name="free")
       import
       type(c_ptr), value :: p
     end subroutine libxc_free
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
