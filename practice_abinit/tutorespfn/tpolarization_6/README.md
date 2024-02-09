# 有限電場計算

## 概要

有限電場下の計算から、誘電率（格子系を含む）やボルン有効電荷を求めることができます。
ABINITには、閃亜鉛鉱型AlPを題材にした例題が付属しています。

`tests/tutorespfn/Input/tpolarization_6.abi`

[公式チュートリアル](https://docs.abinit.org/tutorial/polarization/#3-finite-electric-field-calculations)

## 入力ファイル説明

サンプル入力ファイルは計算時間の短縮を重視して、計算項目と計算量を減らしていますが、簡単な変更で詳細な解析が実行できるように準備ができています。

- 解析対象の電場を3点から11点に拡大
- カットオフエネルギーを大きく

変更箇所を以下に示します。

```diff
--- ../tpolarization_6.abi	2023-07-11 19:23:16.000000000 +0900
+++ ./tpolarization_6.abi	2024-02-07 21:54:03.811755756 +0900
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
+        21  22  23  24  25     # The additional 8 values of the field have been suppressed to save CPU time
+        31  32  33  34  35

 # the initial run is at zero field and uses berryopt -1
 berryopt11 -1
@@ -66,7 +66,7 @@
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
berryopt11 -1
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
nstep 7
toldfe 1.0d-15
```

下記コマンドで計算実行します。
標準出力に途中経過が出力されます。

```sh
mpiexec -np 8 abinit tpolarization_6.abi > Log
```

## 計算結果

計算結果は`tpolarization_6.abo`に出力されています。
収束の様子を確認すると、`toldfe`を満たすことなく、繰り返し回数の上限`nstep`経過時点で各計算を終えています。
それでも電子状態は精度良く収束しています。

```fortran
    iter   Etot(hartree)      deltaE(h)  residm     vres2
 ETOT  1  -9.3393719092084    -9.339E+00 6.227E-02 4.320E+01
 ETOT  2  -9.3618358079721    -2.246E-02 2.543E-05 1.367E+00
 ETOT  3  -9.3621928386010    -3.570E-04 4.377E-06 4.829E-02
 ETOT  4  -9.3621999109098    -7.072E-06 5.948E-08 9.447E-04
 ETOT  5  -9.3621999969982    -8.609E-08 1.342E-09 2.672E-05
 ETOT  6  -9.3622000015009    -4.503E-09 5.438E-11 8.612E-07
 ETOT  7  -9.3622000016232    -1.223E-10 2.139E-12 6.915E-08
```

以下に示す通り、力、分極、応力の電場依存性は、おおむね線形です。
電場の二乗に比例する項を無視します。

## 力

```fortran
 cartesian forces (eV/Angstrom) at end:
    1     -0.01143284891828    -0.01143284891828    -0.01143284891828
    2      0.01143284891828     0.01143284891828     0.01143284891828
```

![force](./images/force.svg)

直線の傾きから求めたAlのボルン有効電荷は2.22です。

## 分極

```fortran
 (S.I.), that is V/m for E, and C/m^2 for P
-      E:   5.142206319E+07   5.142206319E+07   5.142206319E+07
       P:  -1.614708555E+00  -1.614708555E+00  -1.614708556E+00
```

![polarization](./images/polarization.svg)

直線の傾きから求めた電気感受率は6.42、すなわち誘電率は7.42です。

## 応力

```fortran
cartesian_stress_tensor: # hartree/bohr^3
- [  2.65638790E-05,   1.20608889E-06,   1.20608889E-06, ]
- [  1.20608889E-06,   2.65638790E-05,   1.20608889E-06, ]
- [  1.20608889E-06,   1.20608889E-06,   2.65638790E-05, ]
```

![stress](./images/stress.svg)
