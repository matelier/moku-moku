もくもくインストール
=

mokumoku-installation

# 目的

Windows PCに

- WSLを導入し、その上に
- Ubuntuをインストールして、科学技術計算向けの設定を施し、
- 電子状態計算ソフトウェアPHASE/0をインストール

します。

Windows PCは以下の要件を満たすことを前提とします。

- Intel系プロセッサを搭載したWindows10 64bit版(HomeもしくはPro)
- CPUが、仮想化支援機能に対応していること（Intel VT／AMD-V）

一部の操作では管理者権限が必要です。特に、会社所有のPCをご使用の場合はご注意ください。

Macなど、Windows以外の計算機については、[付録A](#付録awindowswsl-ubuntu以外の計算機)にて簡潔に説明します。

## PHASE/0利用講習会参加の前提条件

<details>

<summary>PHASE/0利用講習会に参加予定の方は、事前に以下の事柄を満たしてください。</summary>

- sin関数のグラフが表示できること
- VESTAを使って`samples/Si8`の電荷密度分布が描画できること
- `samples/Si8`の2並列での計算実行が20秒程度以内に終了すること
- テキストエディタの操作に不安がある方は`gedit`をインストールすること

</details>

# 選択肢

環境設定に際し、選択の自由度があります。どれを選ぶのか決めてから、作業に着手してください。

## WSLのバージョン

- WSL1
- WSL2

WSLには、WSL1とWSL2があります。バージョン2は、バージョン1の完全上位版ではありません。また、インストール後に相互変換可能です。

[WSL 1 と WSL 2 の比較 \| Microsoft Docs](https://docs.microsoft.com/ja-jp/windows/wsl/compare-versions)

なお、WSL2に対応した実行基盤上でWSL1を動作させることが可能ですので、実行基盤はWSL2対応のみを説明します。
<!--WSL2はHyper-Vと共存できません。-->

## Xサーバーソフトウェア

- [MobaXterm](https://mobaxterm.mobatek.net)
- [VcXsrv](https://sourceforge.net/projects/vcxsrv/)

一般的にLinux環境では、グラフィックス描画にX Window Systemという仕組みを利用します。その仕組みを利用する（表示を担う）ためのソフトウェアが「Xサーバー」です。[VcXsrv](https://sourceforge.net/projects/vcxsrv/)は、代表的なWindows用のXサーバーソフトウェアです。インストールには管理者権限が必要です。
一方[MobaXterm](https://mobaxterm.mobatek.net)は、Xサーバー付き（他にも盛沢山）の端末ソフトウェアです。WSLで材料シミュレーションを実行する目的にはオーバースペックですが、第一原理計算を本格活用すると手元のパソコンだけでは不十分で、他の（大規模な）計算機を利用するようになります。他の計算機にアクセスする際には、MobaXtermのような端末ソフトウェアが必要になりますので、決して無駄ではありません。MobaXtermには、「インストーラー版」と「ポータブル版」があります。

迷った方には、MobaXtermの「ポータブル版」をお勧めします。


# 環境設定

## Windows用追加ソフトウェアのインストール

WSLの設定に先立ち、Windowsアプリケーションをインストールします。

### Windowsインストーラー利用

Windowsの作法に則ってインストールします。Windowsの管理者権限が必要です。

- [VcXsrv](https://sourceforge.net/projects/vcxsrv/)

![vcxsrv.png](./images/vcxsrv.png)

- [MobaXterm](https://mobaxterm.mobatek.net)

![mobaX.png](./images/mobaX.png)

### ポータブル版

（管理者権限不要です）

ZIPファイルをダウンロードし、展開したものをお好きなディレクトリに配置してください。exeファイルをダブルクリックして実行します。

- [MobaXterm](https://mobaxterm.mobatek.net)

![moba_file.png](./images/moba_file.png)

- [VESTA](http://jp-minerals.org/vesta/jp/)

64bit版の利用をお勧めします。

![VESTA_download.png](./images/VESTA_download.png)

ダウンロードしたZIPファイルを展開します。

![VESTA_file.png](./images/VESTA_file.png)

## WSL実行基盤の設定

マイクロソフト社提供のドキュメントから、かいつまんで説明します。

[Windows 10 に WSL をインストールする \| Microsoft Docs](https://docs.microsoft.com/ja-jp/windows/wsl/install-win10#step-6%E2%80%94install-your-linux-distribution-of-choice)

管理者でサインインして、コントロールパネルから、`プログラムと機能`を選び、ウィンドウ左に並んでいる`Windowsの機能の有効化または無効化`を選ぶと、下に図示するウィンドウが開きます。機能名の左にチェックボックスがありますので、`Linux用Windowsサブシステム`と`仮想マシンプラットフォーム`にチェックを入れてください。`OK`を押すとしばらくして再起動を促されますので、再起動してください。

![top.png](./images/top.png)

![bottom.png](./images/bottom.png)

続けて、`Linuxカーネル更新プログラムパッケージ`をインストールします。ダウンロードして、ダブルクリックするとインストーラーが起動します。

[x64 マシン用 WSL2 Linux カーネル更新プログラム パッケージ](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

## WSLの導入と設定（Ubuntu-20.04）

ここからは（Windowsの）管理者権限不要です。

### OS本体（仮想計算機）

WSL2を利用する場合は、コマンドプロンプト（もしくはPower Shell）を起動して、以下のコマンドを入力してください。今後追加するWSL環境がWSL2に自動設定されます。

```sh
wsl --set-default-version 2
```

導入後のWSL1 <-> WSL2の相互変換は、[付録C](#付録cwsl1とwsl2の相互変換)を参照してください。

WSL上では複数のLinuxディストリビューションが利用できます。ここでは、Ubuntuを利用することを前提に説明します。
Linuxディストリビューションは、Microsoft Storeから入手します。WindowsでMicrosoft Storeを起動した後、検索窓に`Ubuntu`と入力してください。いくつか候補が表示される中から`Ubuntu 20.04LTS`を選び、表示される画面で`入手`もしくは`インストール`を押すとインストールされます。

![store.png](./images/store.png)

インストールするとスタートメニューに`Ubuntu 20.04 LTS`が現れるので、選択してください。ここから、Linuxの世界が始まります。初回起動時に、ユーザー名とパスワードを設定します。ユーザー名は、Windowsのアカウント名とは関係なく設定できます。同じでも良いですが、全角文字の使用はお勧めしません。パスワードにも全角文字を使用しないでください。

```sh
Enter new UNIX username:
New password:
Retype new password:
```

以下の三つのコマンドを実行して、必要なソフトウェア（ライブラリ）を導入します。コマンド実行時にパスワード入力を求められたら、先に設定したパスワードを入力します。

```sh
$ sudo apt update
$ sudo apt upgrade -y
$ sudo apt install -y make gnuplot-x11 gfortran libopenmpi-dev libfftw3-dev evince
```
<!--3, 4行目は、紙面横幅の都合で改行しました。「\」を入力後に`Enter`を押すと、次の行に「>」が表示されるので続きを入力してください。「\」と「>」を省いて、続けて一行で入力しても同じ動作です。-->

各コマンドは実行には時間を要します。ネットワーク環境が良いところで実行してください。ただし、セキュリティに厳しい組織内で実行すると、ファイヤーウォールで通信が遮断される場合があるそうです。

Linux上での作業では、テキストエディタを使用します。標準で`vim`や`nano`はインストールされています。`Emacs`や`gedit`を使いたい人は、追加インストールしてください。

```sh
$ sudo apt install -y emacs
```

```sh
$ sudo apt install -y gedit
```

※PHASE/0利用講習会参加時の注意事項：
いずれのエディタにも不慣れな方向けに、講習会では`gedit`の操作方法を簡潔に説明します。該当する方は`gedit`をインストールしてください。

### X Windows Systemの設定

WSL環境からグラフィックスをWindowsの画面に表示するための設定です。

Xサーバー（VcXsrvもしくはMobaXterm；これらはWindowsのアプリケーションです）を起動してください。

<details>
<summary>VcXsrv</summary>

スタートメニューから、`VcXsrv` - `XLaunch`を選択します。幾つか設定項目があります。最初の二つは「次へ」を押してください。

![vcxsrvinit1.png](./images/vcxsrv/vcxsrvinit1.png)

![vcxsrvinit2.png](./images/vcxsrv/vcxsrvinit2.png)

`Disable access control`にチェックを入れてください。

![vcxsrvinit3.png](./images/vcxsrv/vcxsrvinit3.png)

以上を毎回設定するのは面倒なので、`Save configuration`を押してください。

![vcxsrvinit4.png](./images/vcxsrv/vcxsrvinit4.png)

例えば設定ファイルをデスクトップに配置すると、以下のアイコンが表示されます。これをダブルクリックすると、保存した設定のXサーバーが起動します。

![icon.png](./images/vcxsrv/icon.png)

</details>

<details>
<summary>MobaXterm</summary>

インストール版はスタートメニューから、ポータブル版はZIP展開したファイルを選択して起動します。

![moba_exec.png](./images/moba_exec.png)

</details>

今回はXサーバー（VcXsrvもしくはMobaXterm）とXクライアント（WSLで動作するUbuntu）を単一のWindows PCで動作させますが、WSLは仮想計算機として、Windowsとは別の計算機であるかのように振る舞います。また、大規模な計算機を利用する場合も、その計算機（Xクライアント；PCクラスター、スパコンなど）で描画コマンドを発行し、ネットワークを介して、手元のPC（WindowsのXサーバー）で表示させる使い方が一般的です。その際、Xクライアントに、Xサーバーの画面が（ネットワーク上の）どこにあるのか指示するために、`DISPLAY`環境変数を設定します。

- WSL1の場合

```sh
$ export DISPLAY=localhost:0
```

- WSL2の場合

```sh
$ export DISPLAY=`hostname`.mshome.net:0
```

（参考）Qiita: [WSL2 での DISPLAY 設定](https://qiita.com/taichi-ishitani/items/b627e31a97fef24c6ee4)

Xサーバーの動作を確認します。

```sh
$ gnuplot
```

```
gnuplot> set term x11
gnuplot> plot sin(x)
```

sin関数が表示されれば、Xサーバーが正常に動作しています。

![sin.png](./images/sin.png)

### ファイル共有

WSLは、Windowsから独立した計算機であるかのように動作しますが、ファイルを共有するための仕組みが用意されています。

#### WSLから、Windowsのファイルを読み書きする

WindowsのCドライブは、WSLの`/mnt/c`にマウントされます。例えばWindowsのデスクトップに配置されたファイルは、Cドライブ以下`Users\[ユーザー名]\Desktop\`にあります。

```sh
$ cd /mnt/c/Users/[ユーザー名]/Desktop
$ ls
```

`[ユーザー名]`は、Windowsのユーザー名です。

#### Windowsから、WSLのファイルを読み書きする

WSLのファイルシステムは、Windowsからはネットワークドライブの様に見えます。
エクスプローラーを起動してアドレスバーに`\\WSL$`と入力すると、`Ubuntu-20.04`が表示されます。これがWSLのファイルシステムです。
うかつに操作するとWSL環境を破壊しかねませんので、ご注意ください。

# アプリケーションのコンパイル

## PHASE/0

PHASE/0のソースコードを[ダウンロード](https://azuma.nims.go.jp/cms1/downloads/software/)（登録が必要です）し、`phase0_2021.02.tar.gz`をWindowsのデスクトップに配置します。
Ubuntuを起動し、ホームディレクトリにこれらのファイルをコピーします。

```sh
$ cd
$ cp /mnt/c/Users/[ユーザー名]/Desktop/phase0_2021.02.tar.gz ~
```

ファイルを伸長します。

```sh
$ tar zxf phase0_2021.02.tar.gz
$ cd phase0_2021.02
```

付属する`Makefile.Linux_generic`でコンパイルできます。

```sh
$ cd src_phase
$ make -f Makefile.Linux_generic
```

# 動作検証

続けて、付属サンプル`samples/basic/Si8`で動作を検証します。

```sh
$ cd samples/basic/Si8
```

## PHASE/0：電子状態計算

まず、1コアだけ利用して計算します（非並列）。

```sh
$ ../../../bin/phase
```

ファイル`jobstatus000`（二回目以降の実行では001, 002, ...）に経過時間が出力されます。

```
 status       =      FINISHED
 iteration    =             15
 iter_ionic   =              1
 iter_elec    =             15
 elapsed_time =       201.3720
```

5行目が経過時間（単位：秒）です。

## PHASE/0：並列計算

次に並列計算をテストします。`-np 2`で2並列で実行することを指示します。WSL1では並列実行時にWarningが出力されますが、計算結果に悪影響はありません。

```sh
$ mpiexec -np 2 ../../../bin/phase
```

実行時間が概ね半分になっていれば（半分より少し多くて）正常です。物理コア数以上の並列は実行時間の短縮になりません。

※PHASE/0利用講習会参加時の注意事項：
上記計算の実行時間が3分未満であることを想定したペースで進行します。極端に計算が遅い（実行に長い時間を要する）場合は、前もってご相談ください。

## 電荷密度分布の可視化（VESTA）

上記実行サンプルでは電荷密度分布が出力されていますので、それを描画します。VESTAを起動して、上部メニューから`Files` - `Open...`を選択し、ファイル選択ダイアログからアドレス（フォルダ位置）を以下のように設定します。最初に`\\wsl$`を入力して、マウス操作で選択すると便利です。

```
\\wsl$\Ubuntu-20.04\home\[ユーザー名]\phase0_2021.02\samples\basic\Si8
```

選択可能なファイルとして`nfchr.cube`ファイルが表示されますので、これを選択するとVESTAで描画されます。

![chargeSi8half.png](./images/chargeSi8half.png)

この意味にご興味ある方は、PHASE利用講習会に参加してください。

# 付録A：Windows（WSL Ubuntu）以外の計算機

コンパイラ（C, Fortran）、MPI（並列計算ライブラリ）、FFTW3（高速フーリエ変換ライブラリ）を用意すると何とかなる場合が多いです。
その他 Python3, gnuplot, Emacsなどお好みで追加してください。

## WSLのUbuntu以外のディストリビューション

- Microsoft Store
  - https://aka.ms/wslstore
- Microsoft Store以外
  - [Project List Using wsldl \| Wsldl official documentation](https://wsldl-pg.github.io/docs/Using-wsldl/#distros)

## Mac

[M1 Macへのインストール手順](https://github.com/Materials-Science-Software-Consortium/phase0_install/blob/main/Mac_M1/README.md)を参照してください。

[XQuartz](https://www.xquartz.org)は、Macで動作する代表的なXサーバーです。インストールしてください。

Macのターミナルは、UNIX的に利用できます。仮想計算機ではありませんので、`DISPLAY`環境変数を意識する必要はありません。

## Linux：Ubuntu

使わなくなったWindows PCがあれば、Linuxを実機にインストールして利用できます。
[Ubuntu](https://jp.ubuntu.com)はデスクトップ環境での利用を指向したディストリビューションですが、長期サポート（long-term support; LTS）が提供されていることが魅力です。

`apt`コマンドの引数など、WSLと同じように利用できます。Xサーバーは自動的にインストールされ、Xサーバーとクライアントが正真正銘の同一計算機で動作しますので`DISPLAY`環境変数の設定は不要です。

## Linux：Rocky Linux, AlmaLinux

PCクラスターなど常時稼働している科学技術計算用の実機には、Red Hat Enterprise Linux（以下RHELと記す）もしくはその互換OSが利用されることが多いです。
具体的にはCentOSがその筆頭でしたが、 CentOS 8のEOLが2021年末に変更（短縮）されました（CentOS 7のEOLは2024年6月です）。
[Rocky Linux](https://rockylinux.org/)と[AlmaLinux](https://almalinux.org)は2022年以降も引き続き利用可能なRHEL互換OSの有力候補です。

RHEL互換OSでは、`dnf`コマンドでソフトウェア（ライブラリ）を導入します。

```
$ sudo dnf install -y gcc-gfortran openmpi-devel fftw-static perl gnuplot make patch
```

OpenMPI関連のコマンドは`/usr/lib64/openmpi/bin`以下にインストールされます。
環境変数`PATH`を設定してください。

```
$ export PATH=/usr/lib64/openmpi/bin:$PATH
```

Xサーバーは自動的にインストールされ、Xサーバーとクライアントが正真正銘の同一計算機で動作しますので`DISPLAY`環境変数の設定は不要です。

# 付録B：Windowsのアカウント制御

（まとめ）WSLが利用可能になってさえいれば、その他の項目は管理者権限不要の代替手段があります。

## 管理者権限が必要な作業

- WSLが利用可能になるようにWindowsの設定を変更
- VcXsrvのインストール
- MobaXtermのインストール（インストーラー版；`Program Files`以下にインストールする場合）

## 管理者権限不要

- MobaXtermのインストール（ポータブル版）
- VESTAのインストール
- （WSLが利用可能であることを前提として）Ubuntuをインストールし、それに各種設定を施す；UbuntuのインストールにはMicrosoftアカウントが必要です。


# 付録C：WSL1とWSL2の相互変換

次のコマンドで、ディストリビューション名とそのバージョンを調べます。

```
> wsl -l -v
```

実行結果は以下のようになります。

```
  NAME            STATE           VERSION
* Ubuntu-20.04    Stopped         2
```

ディストリビューション`Ubuntu-20.04`をWSL1に変換するには、以下のコマンドを実行します。

```
> wsl --set-version Ubuntu-20.04 1
```

ディストリビューション`Ubuntu-20.04`をWSL2に変換するには、以下のコマンドを実行します。
```
> wsl --set-version Ubuntu-20.04 2
```
