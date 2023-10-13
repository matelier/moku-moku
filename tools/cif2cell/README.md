# cif2cell

原子スケールの材料シミュレーションでは、実行に際して（初期）原子配置を与えます。

単位格子に含まれる全て（多くの場合複数）の原子座標を、時には対称性を考慮しながら、正確に入力することを利用者に強いているようでは、シミュレーションは普及しません。
この点を改善するために、結晶構造データベースが整備されており、その代表的なファイル書式としてCIFが採用されています。

[cif2cell](https://github.com/torbjornbjorkman/cif2cell)は、CIFから（原子スケールシミュレーションの入力となる）原子配置を生成するオープンソースソフトウェアです。

プログラム本体は継続してメンテナンスされていますが、[マニュアル](https://github.com/torbjornbjorkman/cif2cell/blob/master/docs/cif2cell.pdf)は作成日が2014年4月となっており、更新が滞っているようです。
記述内容が古い可能性に注意しつつ、参考にします。

## CIFについて

かつては、Crystallographic Information Fileの略でしたが、現在は[Crystallographic Information Framework](https://www.iucr.org/resources/cif)の略としても使われています。

全230種の空間群の分類は国際的に定められています。
空間群の種類が決まると、その生成元が決まります。
物質のCIFファイルには空間群の情報と、結晶構造を再現するのに必要な最低限の原子位置が記述されています。
各原子位置に、それぞれ生成元を作用させることにより原子配置を展開すると、結晶構造が出来上がる仕組みです。
この展開作業をcif2cellに手伝ってもらいましょう。

例として、[Materials Project](https://materialsproject.org)からダウンロードしたPt (mp-126, symmetrized)とAl<sub>2</sub>O<sub>3</sub> (mp-1143, symmetrized)のCIF使って説明します。

Materials Projectには、[next-gen](https://next-gen.materialsproject.org/)と[legacy](https://legacy.materialsproject.org/)があり、データ（計算結果）が若干異なります。
ここでは前者`next-gen`（新しい方）のデータ（CIF）を用いた実行結果を示します。

CIFはテキスト形式ですので、そのまま閲覧可能です。
多くの場合格子は、Bravais格子で与えられています。
長さの単位はÅです。

```C
_cell_length_a   3.94315036
_cell_length_b   3.94315036
_cell_length_c   3.94315036
_cell_angle_alpha   90.00000000
_cell_angle_beta   90.00000000
_cell_angle_gamma   90.00000000
```

対称性に関する情報を含みます。

```C
_symmetry_space_group_name_H-M   Fm-3m
（略）
_symmetry_Int_Tables_number   225
（略）
loop_
 _symmetry_equiv_pos_site_id
 _symmetry_equiv_pos_as_xyz
  1  'x, y, z'
  2  '-x, -y, -z'
  3  '-y, x, z'
  4  'y, -x, -z'
  5  '-x, -y, z'
（略）
```

原子位置の情報です。

```C
  Pt  Pt0  4  0.00000000  0.00000000  0.00000000  1
```

## cif2cellのインストール

[Python2系は2020年でサポートが終了しています](https://www.python.org/doc/sunset-python-2/)ので、利用をお勧めしません。
Python3系を使います。

Githubの[インストール手順](https://github.com/torbjornbjorkman/cif2cell#installation-instructions)に沿って、以下コマンドを実行するとインストールできます。

```sh
pip install cif2cell
```

下記のようなエラーになる場合は、Python開発環境を追加インストールしてください。

```
    src/lib/py_star_scan.c:2:10: fatal error: Python.h: No such file or directory
        2 | #include "Python.h"
          |          ^~~~~~~~~~
    compilation terminated.
    error: command '/usr/bin/gcc' failed with exit code 1
```

RHEL系

```sh
sudo dnf install python-devel
```

Ubuntu

```sh
sudo apt install python3-dev
```

（参考）conda環境を利用したインストールも可能です。

```sh
conda install cif2cell
```

## cif2cellの使い方

### 基本的な使い方：マニュアルに記載あり

CIFファイル名を引数に与えてコマンド実行します。

```sh
cif2cell Pt.cif
```

面心立方の基本格子が出力されています。

```C
Bravais lattice vectors :
  0.5000000   0.5000000   0.0000000
  0.5000000   0.0000000   0.5000000
  0.0000000   0.5000000   0.5000000
```

格子ベクトルは、a軸長さを基準にして出力されます。
行列（三つのベクトル）の全要素をa軸長さ（3.94315036 Å）倍すると、格子ベクトルの直交座標表示となります。

Pt基本格子では、原子が一つだけ、原点にあります。

```C
All sites, (lattice coordinates):
Atom           a1          a2          a3
Pt      0.0000000   0.0000000   0.0000000
```

この程度のデータは人手でも簡単に入力できますが、実用的な材料シミュレーションにおいては複雑な結晶も扱います。
Al<sub>2</sub>O<sub>3</sub>では、人手で入力するのが大変な程度に複雑です。
cif2cellの実行方法は同じです。

```sh
cif2cell Al2O3.cif
```

CIFに記述されている原子位置は、AlとOそれぞれ一原子ずつですが、対称性を利用して10原子から成る基本格子（菱面体）が生成されます。

```C
Bravais lattice vectors :
  0.5773503   0.0000000   0.9098979
 -0.2886751   0.5000000   0.9098979
 -0.2886751  -0.5000000   0.9098979
All sites, (lattice coordinates):
Atom           a1          a2          a3
Al      0.1479040   0.1479040   0.1479040
Al      0.3520960   0.3520960   0.3520960
Al      0.6479040   0.6479040   0.6479040
Al      0.8520960   0.8520960   0.8520960
O       0.7500000   0.0561455   0.4438545
O       0.4438545   0.7500000   0.0561455
O       0.5561455   0.2500000   0.9438545
O       0.9438545   0.5561455   0.2500000
O       0.0561455   0.4438545   0.7500000
O       0.2500000   0.9438545   0.5561455
```

ところでこれら原子位置は、格子ベクトルを基準にした相対値ですが、基準となる格子ベクトルは基本格子です。

<details>

<summary>PHASE/0向けの注意事項</summary>

PHASE/0の入力ファイルでは、`coordinate_system = internal`（既定値）で指定する原子位置は、Bravais格子を基準にした相対的な値です。
そのため上記数値そのままでは利用できません。
利用方法はこの後述べます。
なお、Ptは(0,0,0)にのみ原子があるので、どちらの格子ベクトルを基準にしても同じです。

</details>

実行時オプションにより、結晶構造の加工ができます。

`--no-reduce`オプションを与えると、Bravais格子を生成します。

```sh
cif2cell Pt.cif --no-reduce
```

4原子から成るBravais格子が生成されます。
格子ベクトルは、立方体を構成します。

Al<sub>2</sub>O<sub>3</sub>では、30原子から成るBravais格子（六方晶）が生成されます。

```sh
cif2cell Al2O3.cif --no-reduce
```

この座標値は、Bravais格子ベクトルを基準にしており、PHASE/0でそのまま利用できます。

不純物や欠陥を含む結晶を扱う場面で、スーパーセルを用いることがあります。
その原子配置を生成することができます。
オプション`--supercell=[2,2,2]`を指定すると、格子を縦横高さ方向に各2倍した原子配置が生成されます。
実用的に、基本格子に対しては`--no-reduce`と同時指定することが多くなるでしょう。

```sh
cif2cell Pt.cif --no-reduce --supercell=[2,2,2]
```

Bravais格子（4原子）を2x2x2倍（8倍）した、計32原子の配置が生成されます。

この`--supercell`オプションには`ベクトル`を与えましたが、`行列`を与えることもできます。
例えば、面心立方基本格子をBravais格子に変換する行列が、マニュアルの式(1)に示されています。

```math
\begin{pmatrix}
1 & 1 & -1 \\
1 & -1 & 1 \\
-1 & 1 & 1
\end{pmatrix}
```

下記実行例では、この行列を与えてBravais格子を生成します。

```sh
cif2cell Pt.cif --supercell=[[1,1,-1], [1,-1,1], [-1,1,1]]
```

また、マニュアルの式(3)には、六方晶の $\sqrt{3} \times \sqrt{3}$ 構造を生成する行列が紹介されています。

```math
\begin{pmatrix}
2 & 1 & 0 \\
-1 & 1 & 0 \\
0 & 0 & 1
\end{pmatrix}
```

行列を与える方法は応用範囲が広いので、後ほど改めて説明します。

表面の解析をする際に、結晶を指定する面方位を切り出す作業は面倒です。
これもcif2cellが助けてくれます。
Ptの(111)面を切り出すには、複数のオプションを組み合わせます。

- `--cubic-diagonal-z`で、(111)方向（立方体の対角線方向）がz軸に一致するように回転します。
- 回転した格子は、菱面体の基本格子とみなすことができますので、それを六方晶に変換します。その行列はマニュアルの式(4)に示されています。
- 変換後の、生成された格子のa-b面 (x-y面)は、Ptの(111)面です。

```sh
cif2cell Pt.cif --cubic-diagonal-z --supercell=[[1,-1,0], [0,1,-1], [1,1,1]]
```

さらに、表面（スラブ）作成に役立つオプションが用意されています。

- `--supercell-translation-vetor=[0,0,0.023]`を使うと、z方向に格子長さの0.023倍だけ、全ての原子を並行移動します。
- `--supercell-vaccum=[0,0,1]`とすると、c軸方向に格子長さと同じだけの真空層を設けます。その結果、c軸長さは二倍になります。

### 少し進んだ使い方：マニュアルに記載なし

[マニュアル](https://github.com/torbjornbjorkman/cif2cell/blob/master/docs/cif2cell.pdf)には説明のない便利な機能がたくさん備わっています。
ヘルプメッセージを見ながら、便利な機能を探してみると良いでしょう。

```sh
cif2cell -h
```

先ほど、行列を指定して格子を変換する操作を紹介しました。
この機能を利用してPt(111)面を切り出す方法を説明しましたが、適切な行列を見つけることは容易ではありません。
そのような場合は`-surface-wizard`オプションを使うと、行列を教えてくれます。
(111)面を切り出す行列を知りたい場合は、以下のように実行します。

```sh
$ cif2cell Pt.cif --surface-wizard=[1,1,1]
--supercell=[[1,0,-1],[1,-1,0],[1,1,1]]
```

出力をコピーして、次のコマンド実行の引数として利用します。

六方晶の格子を、直方体に取り直したい場合も、行列を与えるだけで変換できます。

```sh
cif2cell Al2O3.cif --no-reduce --surface-wizard=[[1,-1,0], [1,1,0], [0,0,1]]
```

30原子のBravais格子の体積を二倍にした、60原子の直方体の格子が生成されます。
