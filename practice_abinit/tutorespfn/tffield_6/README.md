# 有限電場計算（9.6以前向け）

9.8以降、同じ趣旨の例題が
`tests/tutorespfn/Input/tpolarization_6.abi`
に変更されました。

[公式チュートリアル](https://docs.abinit.org/tutorial/polarization/#3-finite-electric-field-calculations)も更新されています。

以下、9.6以前向けの古い情報を記録として残します。

## 概要

有限電場下の計算から、誘電率（格子系を含む）やボルン有効電荷を求めることができます。
ABINITには、閃亜鉛鉱型AlPを題材にした例題が付属しています。

`tests/tutorespfn/Input/tffield_6.abi`

## 入力ファイル説明

サンプル入力ファイルは計算時間の短縮を重視して、計算項目と計算量を減らしていますが、簡単な変更で詳細な解析が実行できるように準備ができています。

- 解析対象の電場を3点から11点に拡大
- カットオフエネルギーを大きく

変更箇所を以下に示します。

```diff
--- ../tffield_6.abi	2021-11-09 18:58:44.000000000 +0900
+++ ./tffield_6.abi	2022-04-27 21:37:07.211324519 +0900
@@ -8,11 +8,11 @@
 # of the field

 # we can run many (11) fields, or just 3, to make a quick run.
-# ndtset  11
-  ndtset   3
+ ndtset  11
+#  ndtset   3
 jdtset  11
-        21  # 22  23  24  25     # The additional 8 values of the field have been suppressed to save CPU time
-        31  # 32  33  34  35
+        21   22  23  24  25     # The additional 8 values of the field have been suppressed to save CPU time
+        31   32  33  34  35

 # the initial run is at zero field and uses berryopt -1
 berryopt11 -1       rfdir11    1 1 1
@@ -66,7 +66,7 @@ xred
 0 0 0

 #Numerical parameters of the calculation : planewave basis set and k point grid
-ecut  5 # this value is very low but is used here to achieve very low calculation times.
+ecut  20 # this value is very low but is used here to achieve very low calculation times.
         # in a production environment this should be checked carefully for convergence and
         # a more reasonable value is probably around 20
 ecutsm 0.5
```

格子の指定が分かり難い印象を持ちました。

```C
#Definition of the unit cell
acell     3*7.2728565836E+00
rprim
0.0000000000E+00  7.0710678119E-01  7.0710678119E-01
7.0710678119E-01  0.0000000000E+00  7.0710678119E-01
7.0710678119E-01  7.0710678119E-01  0.0000000000E+00
```

AlPのBravais格子の一辺を10.29 Bohr (約5.44Å)として、その1/√2が`7.2728565836`です。
また`rprim`の非零要素`7.0710678119E-01`は、1/√2です。

面心立方格子の場合には、`acell`にBravais格子の長さを与えて、`rprim`を

```C
 0   1/2  1/2
1/2   0   1/2
1/2  1/2   0
```

とする設定がよく用いられますが、本サンプルでは`acell`を√2で割り、`rprim`に√2をかけることで、表現は異なりますが、同じ内容が設定されます。

最初に零電場の計算を実行します。

```fortran
berryopt11 -1       rfdir11    1 1 1
```

それ以降に、非零電場の計算を実行します。
電場印加方向は[111]です。

```fortran
berryopt21  4       efield21   0.0001  0.0001  0.0001    getwfk21  11
```

オリジナルの入力ファイルは、E=0, ±0.0001の3通りの計算ですが、先に述べた変更により、E = -0.0005から+0.0005まで、0.0001刻みで11通りの計算を実行します。

バンド数は、価電子を収容するために必要なだけにします。
非占有バンドを生じてはいけません。

```sh
 nband 4 # nband is restricted here to the number of filled bands only, no empty bands. The theory of
         # the Berrys phase polarization formula assumes filled bands only. Our pseudopotential choice
         # includes 5 valence electrons on P, 3 on Al, for 8 total in the primitive unit cell, hence
         # 4 filled bands.
```

収束条件（`toldfe`）は非常に厳しく設定されていますが、同時に繰り返し回数の上限（`nstep`）が小さ目に設定されています。

```fortran
nstep 8
toldfe 1.0d-15
```

下記コマンドで計算実行します。
標準出力に途中経過が出力されます。

```sh
mpiexec -np 8 abinit tffield_6.abi > Log
```

## 計算結果

計算結果は`tffield_6.bo`に出力されています。
収束の様子を確認すると、`toldfe`を満たすことなく、繰り返し回数の上限`nstep`経過時点で各計算を終えています。
それでも電子状態は精度良く収束しています。

```fortran
     iter   Etot(hartree)      deltaE(h)  residm     vres2
 ETOT  1  -9.3597808803205    -9.360E+00 2.699E-04 3.738E-01
 ETOT  2  -9.3598898044398    -1.089E-04 4.393E-07 2.021E-02
 ETOT  3  -9.3598950927905    -5.288E-06 4.160E-07 4.057E-04
 ETOT  4  -9.3598951681507    -7.536E-08 4.015E-07 1.006E-05
 ETOT  5  -9.3598951694422    -1.292E-09 3.993E-07 3.653E-07
 ETOT  6  -9.3598951694934    -5.115E-11 3.990E-07 1.291E-08
 ETOT  7  -9.3598951694953    -1.966E-12 3.990E-07 2.948E-10
 ETOT  8  -9.3598951694954    -8.704E-14 3.990E-07 8.218E-12
```

以下に示す通り、力、分極、応力の電場依存性は、おおむね線形です。
電場の二乗に比例する項を無視します。

## 力

```fortran
 cartesian forces (eV/Angstrom) at end:
    1     -0.01143276583117    -0.01143276583117    -0.01143276583117
    2      0.01143276583117     0.01143276583117     0.01143276583117
```

![force](./images/force.svg)

直線の傾きから求めたAlのボルン有効電荷は2.22です。

## 分極

```fortran
 (S.I.), that is V/m for E, and C/m^2 for P
-      E:   5.142206319E+07   5.142206319E+07   5.142206319E+07
       P:  -1.614708582E+00  -1.614708582E+00  -1.614708582E+00
```

![polarization](./images/polarization.svg)

直線の傾きから求めた電気感受率は6.42、すなわち誘電率は7.42です。

## 応力

```fortran
cartesian_stress_tensor: # hartree/bohr^3
- [  2.65640004E-05,   1.20609702E-06,   1.20609702E-06, ]
- [  1.20609702E-06,   2.65640004E-05,   1.20609702E-06, ]
- [  1.20609702E-06,   1.20609702E-06,   2.65640004E-05, ]
```

![stress](./images/stress.svg)
