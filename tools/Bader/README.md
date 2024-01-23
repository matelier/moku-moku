# Bader

Bader電荷解析を実施する標準的なツールです。
Gaussian CUBE形式のファイルを処理するので、多くの電子状態計算ソフトウェアの結果解析に利用できます。

## ソフトウェア情報

公式サイトはこちらです。

http://theory.cm.utexas.edu/henkelman/research/bader/

http://theory.cm.utexas.edu/henkelman/code/bader/

実行形式ファイル(Linux x86_64, Mac OS X)もしくはソースコードをダウンロードします。
macOS用は、arm64 (Apple Silicon)向けと思われます。

最新版は`1.05`です。

```sh
  GRID BASED BADER ANALYSIS  (Version 1.05 08/19/23)
```

ライセンスはGPL3です。

```text
! Copyright 2006-2020
! Wenjie Tang, Andri Arnaldsson, Wenrui Chai, Samuel T. Chill, and Graeme Henkelman
!
! Bader is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! A copy of the GNU General Public License is available at
! http://www.gnu.org/licenses/
```

## コンパイル

ソースコードにはMakefileが同梱されています。
私のmacOS環境では、`makefile.osx_gfortran`をそのまま使うとリンクでエラーになりました。
`-static`オプションを無効化するとコンパイルできました。

```makefile
#LINK = -static
```

```sh
make -f makefile.osx_gfortran
```

## その他

Intel MacはAnaconda (miniconda)でインストールできるようです。

https://anaconda.org/conda-forge/bader

```sh
conda install conda-forge::bader
```
