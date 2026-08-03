# OpenMXの練習

## インストール

Linuxに[Intel oneAPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/toolkits.html)をインストールしてコンパイルするのが[最も確実な手順](https://github.com/matelier/moku-moku/blob/master/installation/wsl_rocky_oneapi.md#openmx)です。

## 基本的な操作

### 入力ファイル書式

[マニュアル英語](https://www.openmx-square.org/openmx_man4.0/s8_input-file.html)

[マニュアル日本語](https://www.openmx-square.org/openmx_man4.0jp/s8_input-file.html)

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

[マニュアル英語](https://www.openmx-square.org/openmx_man4.0/s12_3_basis-db2019.html)

[マニュアル日本語](https://www.openmx-square.org/openmx_man4.0jp/s12_3_basis-db2019.html)

### 電荷密度混合法の選択

> 小さなギャップを持つ系や金属系ではcharge sloshingが深刻になりやすく、 Kerker, RMM-DIISK, RMM-DIISVが有効です。

> plus $U$ 法や拘束法ではRMM-DIISHがより自然な選択になることがあります。

[マニュアル英語](https://www.openmx-square.org/openmx_man4.0/s16_1_scf-convergence-overview.html)

[マニュアル日本語](https://www.openmx-square.org/openmx_man4.0jp/s16_1_scf-convergence-overview.html)

### 一部の原子のみを構造最適化の対象とする方法

[マニュアル英語](https://www.openmx-square.org/openmx_man4.0/s18_4_constraints.html)

[マニュアル日本語](https://www.openmx-square.org/openmx_man4.0jp/s18_4_constraints.html)

### 途中で計算を安全に停止させる

[マニュアル英語](https://www.openmx-square.org/openmx_man4.0/s16_3_otf-scf.html)

[マニュアル日本語](https://www.openmx-square.org/openmx_man4.0jp/s16_3_otf-scf.html)
