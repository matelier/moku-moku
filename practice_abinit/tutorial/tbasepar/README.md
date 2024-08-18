# ABINITの並列計算：k点並列とスピン並列

実用上、第一原理電子状態計算に並列計算は必須です。
並列計算に対する理解を深めることは、効率的な計算遂行に役立ちます。

[公式チュートリアル](https://docs.abinit.org/tutorial/basepar/)に沿って、並列計算の基礎（k点並列とスピン並列）を説明します。

## k点並列

`tests/tutorial/Input/tbasepar_1.abi`

面心立法格子の鉄の例題です。
磁性を考慮していません。
k点数が多いことに特徴があります。
この例で、k点並列による計算時間短縮を確認します。

最初に、非並列で実行します。

```sh
abinit tbasepar_1.abi
```

出力ファイル`tbasepar_1.abo`を確認します。

```C
-    mband =           7        mffmem =           1         mkmem =         182
       mpw =        1418          nfft =       32768          nkpt =         182
```

k点数は182 (`nkpt`)で、1プロセスが182 (`mkmem`)個（要するに全て）の計算処理を担当したことが示されています。

同ファイルの末尾を見ます。

```C
- Proc.   0 individual time (sec): cpu=         43.4  wall=         43.9

================================================================================

 Calculation completed.
.Delivered  11 WARNINGs and   2 COMMENTs to log file.
+Overall time at end (sec) : cpu=         43.4  wall=         43.9
```

計算時間（経過時間）が43.9秒であったことが出力されています。

次に2並列で実行します。

```sh
mpiexec -n 2 abinit tbasepar_1.abi
```

同様に、出力ファイル`tbasepar_1.abo`を確認します。

```C
-    mband =           7        mffmem =           1         mkmem =          91
       mpw =        1418          nfft =       32768          nkpt =         182
```

非並列の場合と同じく、k点数は182 (`nkpt`)です。
1プロセスが担当するk点数は半分の91 (`mkmem`)個であることがわかります。

```C
- Proc.   0 individual time (sec): cpu=         23.7  wall=         24.2

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         47.9  wall=         48.4
```

2並列したことにより、計算時間は24.2秒に短縮されました。
この間、二つのCPU（コア）が動いていますので、のべ経過時間（最終行の`wall`）は48.4秒です。
並列計算が理想的に実行されると、この時間は非並列の43.9秒と同じですが、現実の並列計算には無駄が生じます。
のべ経過時間が非並列と比べて大きいほど、並列の無駄が大きいことを示しています。
一般に、並列数を増やせば増やすほど、無駄が多くなります。

このようにABINITは、（並列に関する指定を省略すると）k点並列で計算を実行します。

さらに4並列を試します。

```sh
mpiexec -n 4 abinit tbasepar_1.abi
```

```C
-    mband =           7        mffmem =           1         mkmem =          46
       mpw =        1418          nfft =       32768          nkpt =         182
```

1プロセスが担当するk点数は、182が4で割り切れないので、小数点以下を切り上げて46になりました。

```C
- Proc.   0 individual time (sec): cpu=         13.2  wall=         13.8

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         54.4  wall=         55.0
```

計算時間は短くなりましたが、のべ経過時間は一層長くなりました。
この例では、k点数が並列数で割り切れないことも、並列効率を下げる一因です。

このように、計算時間の短縮と、のべ経過時間の増加（並列計算の無駄）を見ながら、適切な並列数を選びます。

## スピン並列

（コリニア計算における）アップ・ダウン各スピンの計算（内部処理）は、異なるk点の計算と似ています。
アップスピンとダウンスピンを（異なるk点であるかのように扱って）、k点並列に参加させるのがスピン並列です。

`tests/tutorial/Input/tbasepar_2.abi`

こちらは先ほどの例題と異なり、k点数が（極端に）少ない例題です。
スピン並列の効果が際立つように、意図的にk点数を少なくしている、とのことです。

最初に、非並列で実行します。

```sh
abinit tbasepar_2.abi
```

出力ファイル`tbasepar_2.abo`を確認します。

```C
-    mband =          40        mffmem =           1         mkmem =           1
       mpw =        4013          nfft =       64000          nkpt =           1
```

k点数は1 (`nkpt`)で、1プロセスが担当するk点数も1 (`mkmem`)個です。

計算時間を確認します。

```C
- Proc.   0 individual time (sec): cpu=         10.8  wall=         11.3

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   2 COMMENTs to log file.
+Overall time at end (sec) : cpu=         10.8  wall=         11.3
```

11.3秒でした。

続けて2並列で実行します。

```sh
mpiexec -n 2 abinit tbasepar_2.abi
```

出力ファイル`tbasepar_2.abo`を確認しますが、非並列と大きな違いはありません。

```C
-    mband =          40        mffmem =           1         mkmem =           1
       mpw =        4013          nfft =       64000          nkpt =           1
```

k点に関する情報は、非並列と同一です。

計算実行時間には差があります。

```C
- Proc.   0 individual time (sec): cpu=          6.4  wall=          6.9

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         13.3  wall=         13.8
```

スピン並列によって計算時間は短くなっていますが、k点並列の2並列よりも、無駄が多い印象です。

それ以上に並列するとどうなるでしょうか。
4並列で実行してみました。

```sh
mpiexec -n 4 abinit tbasepar_2.abi
```

計算は正常に終了しました。
実行時間を確認します。

```C
- Proc.   0 individual time (sec): cpu=          6.5  wall=          7.0

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         27.4  wall=         28.0
```

実行時間は2並列とほぼ同じです。
2並列以上はエラーになりませんが、計算速度向上はありません。

k点並列とスピン並列は同時に利用できます。
それを確認するために、入力ファイルを書き換えてk点数を増やします。

```diff
--- ../tbasepar_2.abi   2023-07-11 19:23:16.000000000 +0900
+++ ./tbasepar_2.abi    2024-02-09 18:19:39.135173754 +0900
@@ -22,7 +22,7 @@

 #Numerical parameters of the calculation : planewave basis set and k point grid
 ecut   39
-ngkpt  2 2 2
+ngkpt  4 4 4
 shiftk 0.5 0.5 0.5
 occopt 7
 nband  40
```

この変更により、k点数（`nkpt`）が4になります。

これを2並列で実行します。

```sh
mpiexec -n 2 abinit tbasepar_2.abi
```

スピン並列が優先され（チュートリアルの説明と異なるようです）、k点については並列されていません。

```C
-    mband =          40        mffmem =           1         mkmem =           4
       mpw =        4001          nfft =       64000          nkpt =           4
```

```C
- Proc.   0 individual time (sec): cpu=         19.4  wall=         20.0

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         39.3  wall=         39.9
```

4並列で実行すると、スピン並列＋k点2並列で動作します。

```C
-    mband =          40        mffmem =           1         mkmem =           2
       mpw =        4001          nfft =       64000          nkpt =           4
```

```C
- Proc.   0 individual time (sec): cpu=         11.4  wall=         12.1

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         47.6  wall=         48.3
```

3並列で実行すると、スピン自由度×k点数の8を、 $3 + 3 + 2$ に三分割して、並列計算します。

```C
-    mband =          40        mffmem =           1         mkmem =           3
       mpw =        4001          nfft =       64000          nkpt =           4
```

```C
- Proc.   0 individual time (sec): cpu=         15.9  wall=         16.6

================================================================================

 Calculation completed.
.Delivered   1 WARNINGs and   0 COMMENTs to log file.
+Overall time at end (sec) : cpu=         49.0  wall=         49.7
```

## その他の並列

k点並列とスピン並列の組み合わせだけでは、大規模系を効率よく並列計算することはできません。

ABINIT（だけでなく、多くの平面波擬ポテンシャルの第一原理計算）ではその他に、

- バンド並列
- 平面波並列（G並列）
- （スレッド並列）

が利用できます。

[バンドと平面波の並列はこちら](../../tutoparal/tparal_bandpw/README.md)を参照してください。
