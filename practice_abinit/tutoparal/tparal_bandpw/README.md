# KGB並列：k点、平面波、バンド

ABINITでは、詳細指定なしに並列計算すると、k点並列＋スピン並列が用いられることを確かめました。
この並列はシンプルでわかりやすいのですが、大規模計算を効率よく実行するためには十分とは言えません。

ABINITには、他にも効率良い並列計算のための仕組みが備わっています。
それらの利用方法を学びます。

`tests/tutoparal/Input/tparal_bandpw_01.abi`

107個の金原子を扱った例題ですが、物理現象のシミュレーションとしては適切でない設定が含まれています。
並列計算を理解する題材として利用します。
k点が一つだけで、スピンを考慮していないので、先に学んだ方法では並列計算できません。

公式チュートリアルでは、64CPU（コア）利用可能な実行環境向けに説明されていますが、ここでは24CPU（コア）環境向けに変更して説明します。
まず、各入力ファイルのバンド数`nband`を`624`に変更します。
これは、バンド数を並列数の倍数にするためです。
チュートリアルで、64並列に対してその10倍、640バンドに設定されているのは意図的と思われます。

またカットオフエネルギーが非常に（物理現象の再現には不適切な程度に）小さな値が設定されています。
そしてチュートリアルに沿って実行すると、並列に関して説明文と定性的に異なる振る舞いが見られました。
カットオフエネルギーを（実用上最低限必要な程度に）大きくすると、チュートリアル説明文に即した振る舞いが確認できました。
以下の実行例は、チュートリアルとして意味を成すように、カットオフエネルギーを変更して実行しました。

```C
ecut          15 # Irrealist. Just to reduce the computation time in order to perform some benchmark
pawecutdg     20 # Minimal value not converge to run with ecut
```

（一部比較のために、オリジナルのカットオフで実行しました。）

## 並列数の自動決定

`autoparal`を`1`に、`max_ncpus`には利用したいCPU（コア）数の`24`を指定して、ABINITを実行すると、おすすめの（ただし、良いとは限らない (not so good)）並列実行条件が出力されます。

```sh
autoparal     1
max_ncpus     24
```

```sh
abinit tparal_bandpw_01.abi
```

```C
 Searching for all possible proc distributions for this input with #CPUs<=24:

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 |       np_spkpt|       npfft|      npband|      bandpp|  #MPI(proc)|    WEIGHT|
 |    1<<    1|    1<<   24|    1<<   24|    1<<  648|    1<<   24|  <=    24|
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 |           1|           4|           6|          36|          24|    17.128|
 |           1|          12|           2|         108|          24|    16.432|
 |           1|           8|           3|          72|          24|    16.217|
 |           1|           6|           4|          54|          24|    15.896|
 |           1|           2|          12|          18|          24|    15.545|
 |           1|           8|           3|          54|          24|    15.523|
 |           1|           4|           6|          54|          24|    14.251|
 |           1|           4|           6|          18|          24|    14.192|
 |           1|          12|           2|         162|          24|    13.694|
 |           1|          10|           2|         108|          20|    13.672|
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Only the best possible choices for nproc are printed...
```

`WEIGHT`が最も大きい`npband` ✖️ `npfft` = ($6 \times 4$)が推奨の組み合わせです。
（この結果は、オリジナルの小さなカットオフエネルギーで実行しても同じでした。）

推奨の並列数で実行するためには、入力ファイル`tparal_bandpw_01.abi`を以下のように書き換えます。

```sh
#autoparal     1
#max_ncpus     24
npband        6
npfft         4
```

MPI 24並列でABINITを実行します。

```sh
mpiexec -n 24 abinit tparal_bandpw_01.abi
```

## 並列数の手動探索

並列数の自動決定は簡便ですが、必ずしも最善ではないそうです。
最適な並列数を選択するために、異なる並列の組み合わせで実際に並列計算を実行して経過時間を調べます。

`tests/tutoparal/Input/tparal_bandpw_02.abi`

入力ファイルの並列条件を変更して、それぞれ計算実行します。
忘れずに`nband`を`624`に変更してください。

`npband` ✖️ `npfft` = ($24 \times 1$), ($12 \times 2$), ($8 \times 3$), ($6 \times 4$), ($4 \times 6$)の各条件を候補とします。

```sh
npband        6   # Change this line according to the tutorial
npfft         4   # Change this line according to the tutorial
```

実行結果ファイル`tparal_bandpw_02.abo`を、条件に合わせてぞれぞれ`tparal_bandpw_02.04.06.abo`などにファイル名を変更します。

5ケースの計算が終わったら、全計算の経過時間を調べます。

```sh
$ grep Proc *.abo
tparal_bandpw_02.04.06.abo:- Proc.   0 individual time (sec): cpu=        337.8  wall=        338.7
tparal_bandpw_02.06.04.abo:- Proc.   0 individual time (sec): cpu=        335.3  wall=        336.0
tparal_bandpw_02.08.03.abo:- Proc.   0 individual time (sec): cpu=        350.6  wall=        351.2
tparal_bandpw_02.12.02.abo:- Proc.   0 individual time (sec): cpu=        447.7  wall=        450.0
tparal_bandpw_02.24.01.abo:- Proc.   0 individual time (sec): cpu=        568.7  wall=        569.4
$
```

自動決定の選択の通り、($6 \times 4$)が最も経過時間が短いことが確認できました。

ところで、カットオフエネルギーを変更しない場合には、異なる結果が得られました。

```sh
$ grep Proc *.abo
tparal_bandpw_02.04.06.abo:- Proc.   0 individual time (sec): cpu=         95.4  wall=         96.0
tparal_bandpw_02.06.04.abo:- Proc.   0 individual time (sec): cpu=         90.9  wall=         91.5
tparal_bandpw_02.08.03.abo:- Proc.   0 individual time (sec): cpu=         88.9  wall=         89.5
tparal_bandpw_02.12.02.abo:- Proc.   0 individual time (sec): cpu=         87.2  wall=         87.8
tparal_bandpw_02.24.01.abo:- Proc.   0 individual time (sec): cpu=         86.1  wall=         86.7
$
```

最も経過時間が短いのは、自動決定（`autoparal = 1`）の結果とは異なり、($24 \times 1$)でした。

この振る舞いは、利用している計算機や計算対象、計算条件に依存するようですので、計算速度が重要な場面では、個別に確認した方が良いでしょう。

## 収束性の確認

ここまで同一繰り返し回数での実行時間（繰り返し一回あたりの計算時間）に注目してきました。

ところで、並列計算の目的は、繰り返し計算を速く回すことではなく、電子状態を速く収束させることです。
繰り返し一回あたりの計算時間は長くても、少ない繰り返し回数で電子状態が収束に至れば、トータルの計算時間は短くなる可能性があります。
以下コマンドで収束性を確認します。

```sh
$ grep "ETOT  5" *.abo
tparal_bandpw_02.04.06.abo: ETOT  5  -3672.7471436645     1.398E-01 2.003E-04 1.510E+00
tparal_bandpw_02.06.04.abo: ETOT  5  -3672.7459369761     1.321E-01 1.391E-04 1.467E+00
tparal_bandpw_02.08.03.abo: ETOT  5  -3672.7449548806     1.283E-01 1.683E-04 1.333E+00
tparal_bandpw_02.12.02.abo: ETOT  5  -3672.7446319148     1.197E-01 9.563E-05 1.291E+00
tparal_bandpw_02.24.01.abo: ETOT  5  -3672.7460450165     1.079E-01 1.199E-04 1.155E+00
$
```

各行最後の数値は残差であり、これが小さいほど、収束が良いことを意味します。
チュートリアルで説明されている通り、`npband`が大きいほど残差が小さく、収束性が良いことがわかります。

ここで、新たなパラメータ`bandpp`が登場します。

収束性の観点から、`npband`が大きい方が好ましいことを確認しました。
`bandpp`は、収束性の観点では`npband`を`bandpp`倍する効果があります。
その反面、繰り返し一回の実行時間は長くなります。

`bandpp`の効果を確認する例題がこちらです。

`tests/tutoparal/Input/tparal_bandpw_03.abi`

上手に設定すれば、計算時間の少しの増加で、収束性を改善できます。

## KGB並列

k点数を増やして、k点並列と併せて使います。

```sh
#nkpt          1
ngkpt         4 4 4
```

k点数が4の計算になります。

`autoparal = 1`の実行結果です。

```C
 Searching for all possible proc distributions for this input with #CPUs<=24:

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 |       np_spkpt|       npfft|      npband|      bandpp|  #MPI(proc)|    WEIGHT|
 |    1<<    4|    1<<   22|    1<<   24|    1<<  624|    1<<   24|  <=    24|
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 |           4|           3|           2|         312|          24|    19.089|
 |           4|           6|           1|         208|          24|    17.947|
 |           4|           2|           3|          52|          24|    17.823|
 |           4|           6|           1|         156|          24|    17.625|
 |           3|           2|           4|          52|          24|    17.282|
 |           1|           3|           8|          26|          24|    17.183|
 |           2|           3|           4|          52|          24|    17.028|
 |           2|           2|           6|          26|          24|    17.003|
 |           4|           2|           3|         104|          24|    16.867|
 |           2|          12|           1|         208|          24|    16.838|
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Only the best possible choices for nproc are printed...
 ```

推奨の並列で実行するためには、入力ファイルに以下のように記述します。

```sh
paral_kgb     1
np_spkpt      4
npband        2
npfft         3
```