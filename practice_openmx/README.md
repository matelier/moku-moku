# OpenMXの練習

## インストール

Linuxに[Intel oneAPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/toolkits.html)をインストールしてコンパイルするのが最も確実な手順です。

## 基本的な操作

### 入力ファイル書式

http://www.openmx-square.org/openmx_man3.9jp/node19.html

`#`以降はコメントです。

大文字と小文字は区別されません。

### 並列計算実行

```sh
mpiexec -np 4 openmx [入力ファイル]
```

計算実行ログが標準出力に書き出されます。

少ない並列数では、MPI並列での実行をお勧めします（スレッド並列を使わない）。

### 基底関数ファイルへのPATH

既定値は相対PATHで`../DFT_DATA19/`です。
付属サンプルの実行には適しますが、自分の課題実行の際には変更した方がわかりやすいでしょう。
基底関数ファイルの置き場所を決めて、絶対PATHで指定することをお勧めします。

```
DATA.PATH           /opt/OpenMX/DFT_DATA19
```

### 基底関数を選ぶ

要求される計算精度（許容される計算負荷）に応じて、推奨される基底関数を選択します。

http://www.openmx-square.org/openmx_man3.9/node27.html
http://www.openmx-square.org/openmx_man3.9jp/node27.html

### 電荷密度混合法の選択

> 多くの場合で、「RMM-DIISK」と「RMM-DIISV」が最良の選択となります。

> 我々の経験上、plus $U$法と拘束法には「RMM-DIISH」が適切です。

http://www.openmx-square.org/openmx_man3.9jp/node40.html

### 一部の原子のみを構造最適化の対象とする方法

http://www.openmx-square.org/openmx_man3.9/node51.html
http://www.openmx-square.org/openmx_man3.9jp/node51.html

### 途中で計算を安全に停止させる

http://www.openmx-square.org/openmx_man3.9jp/node42.html
