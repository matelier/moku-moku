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
執筆時点の最新版は6.2.2です。
セキュリティ設定の問題からか、ブラウザやウィルス対策ソフトウェアの組み合わせによってはダウンロードできない場合があるようです。
ダウンロードできない場合は、ブラウザを変えるなどお試しください。

Linuxの標準的な手順でインストールします。
oneAPIを利用する場合は、Cコンパイラのコマンドを指定します（`CC=icx`）。
インストール先は、ホームディレクトリ直下の`local`としてみます。

```sh
tar xf libxc-6.2.2.tar.gz
cd libxc-6.2.2
./configure CC=icx --prefix=$HOME/local
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
執筆時点の最新版は9.2.12です。

```sh
tar xf elk-9.2.12.tgz
cd elk-9.2.12
```

`make.inc`を編集します。
コンパイラは、最初からoneAPI（Intelコンパイラ）を利用するように設定されています。
Libxcを有効にするために、

```makefile
#LIB_LIBXC = libxcf90.a libxc.a
#SRC_LIBXC = libxcf90.f90 libxcifc.f90
```

の各行先頭`#`を消去してください。

インストール済みLibxcから、`$HOME/local/lib`にある`libxc.a`と`libxcf90.a`の二つを、Elkの`src`ディレクトリにコピーします。

```sh
cp $HOME/local/lib/libxcf90.a src
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
