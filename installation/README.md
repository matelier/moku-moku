# もくもくインストール

mokumoku-installation

## 目的と概要

Windows PCに

- WSLを導入し、その上に
- Ubuntuをインストールして、科学技術計算向けの設定を施し、
- 電子状態計算ソフトウェアPHASE/0をインストール

します。

Windows PCは以下の要件を満たすことを前提とします。

- Intel系プロセッサを搭載したWindows10もしくは11の64bit版(HomeもしくはPro)
- CPUが、仮想化支援機能に対応していること（Intel VT／AMD-V）

一部の操作では管理者権限が必要です。特に、会社所有のPCをご使用の場合はご注意ください。

Macなど、Windows以外の計算機については、[付録A](#付録awindowswsl-ubuntu以外の計算機)にて簡潔に説明します。

### WSLのバージョン

WSLには、WSL1とWSL2があり、現在の既定値はWSL2です。
WSL2はWSL1の完全な上位バージョンではありませんが、WSL2の使用を強くお勧めします。

[WSL 1 と WSL 2 の比較 \| Microsoft Docs](https://docs.microsoft.com/ja-jp/windows/wsl/compare-versions)

後述するWSLgは、WSL2で動作します。

なお、WSL1とWSL2は、インストール後に相互変換可能です。
<!-- なお、WSL2に対応した実行基盤上でWSL1を動作させることが可能ですので、実行基盤はWSL2対応のみを説明します。 -->
<!--WSL2はHyper-Vと共存できません。-->

### WSL環境でのGUI実行 (WSLg)

一般的にLinux環境では、グラフィックス描画にX Window System (X11)という仕組みを利用します。
（近年、Waylandへの置き換えが進んでいる、そうです。）
その仕組みの利用に際して、表示を担うソフトウェアが「Xサーバー」です。

かつて、WSLでグラフィカルアプリケーションを利用するには、Xサーバー（Windowsアプリケーション）が必要でした。
現在は、WSLがグラフィカルアプリケーション（X11とWayland両方）の実行をサポートしています（WSLgと呼ばれます）。

[Linux 用 Windows サブシステムで Linux GUI アプリを実行する](https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/gui-apps)

仮想GPU用のドライバーをインストールしてください。

## 環境設定

### WSL実行基盤の設定とUbuntuのインストール

WSLのインストール手順はシンプルです。

スタートメニューの右クリックから、管理者権限のWindows PowerShell（もしくはコマンドプロンプト）を起動し、以下コマンドを実行するだけで、Ubuntu（ディストリビューションの既定値；2022年12月時点では`22.04 LTS`）がインストールされます。

```sh
wsl --install
```

[WSL を使用して Windows に Linux をインストールする](https://docs.microsoft.com/ja-jp/windows/wsl/install)

再起動を促された場合は、指示に従って再起動してください。
サインインすると[初回起動](#初回起動)が始まります。

このコマンドは、

- WSL実行基盤が整っていない場合は、それを整えてから
- ディストリビューションをインストール

します。
前者「実行環境を整える」には管理者権限が必要ですが、後者のディストリビューションのインストールに管理者権限は不要です。
前者のみを実行するコマンドは無いようですので、インストールされるディストリビューションが不要な場合はインストール後に削除するか、[手動で実行環境を整えて](https://github.com/matelier/moku-moku/blob/f373f46d1a4a65810831cd8394f5451433429040/installation/README.md)ください。
また、`WSL`がすでにインストールされている場合、上記コマンドはヘルプメッセージを表示して終了します。
次節以降を参照して、[ディストリビューションを指定したオンラインインストール](#既定値以外のディストリビューションのオンラインインストール)、もしくは、[Microsoft Storeからインストール](#microsoft-storeからのディストリビューション導入)してください。
普段、管理者権限を持たない一般ユーザーとしてサインインしている方は、管理者としてサインインしてコマンド実行することをお勧めします。
一般ユーザーとしてサインインして、管理者権限のWidows PowerShell（もしくはコマンドプロンプト）から上記コマンドを入力した場合は、`Ubuntu`は管理者アカウントにインストールされますのでご注意ください。

また、WSL環境を整えてからしばらく使っていなかった場合は、次のコマンドでアップデートすることをお勧めします。（Windowsの管理者権限が必要です）

```sh
wsl --update
```

なお、管理者がディストリビューションをインストールすると、WSL2になるようです。
管理者として実行基盤を整え、一般ユーザーがディストリビューションをインストールした場合は、WSL1が既定値です。
一般ユーザーも既定値をWSL2にするためには、以下コマンドを実行します。

```sh
wsl --set-default-version 2
```

導入後のWSL1 <-> WSL2の相互変換は、[付録C](#付録cwsl1とwsl2の相互変換)を参照してください。

#### 既定値以外のディストリビューションのオンラインインストール

`wsl --install`コマンドでインストール（オンラインインストール）できるのは`Ubuntu`だけではありません。
以下のコマンドで、オンラインインストール可能なディストリビューション一覧が表示されます。

```powershell
PS C:\Users\matelier> wsl -l --online
The following is a list of valid distributions that can be installed.
Install using 'wsl --install -d <Distro>'.

NAME                                   FRIENDLY NAME
Ubuntu                                 Ubuntu
Debian                                 Debian GNU/Linux
kali-linux                             Kali Linux Rolling
Ubuntu-18.04                           Ubuntu 18.04 LTS
Ubuntu-20.04                           Ubuntu 20.04 LTS
Ubuntu-22.04                           Ubuntu 22.04 LTS
Ubuntu-24.04                           Ubuntu 24.04 LTS
OracleLinux_7_9                        Oracle Linux 7.9
OracleLinux_8_7                        Oracle Linux 8.7
OracleLinux_9_1                        Oracle Linux 9.1
openSUSE-Leap-15.5                     openSUSE Leap 15.5
SUSE-Linux-Enterprise-Server-15-SP4    SUSE Linux Enterprise Server 15 SP4
SUSE-Linux-Enterprise-15-SP5           SUSE Linux Enterprise 15 SP5
openSUSE-Tumbleweed                    openSUSE Tumbleweed
PS C:\Users\matelier>
```

例えば`Ubuntu 24.04LTS`をオンラインインストールするためには下記コマンドを実行します。

```sh
wsl --install -d Ubuntu-24.04
```

#### Microsoft Storeからのディストリビューション導入

オンラインインストールできないけれども、Microsoft Storeから提供されているディストリビューションもあります。

例えば、Microsoft Storeにて、`wsl`で検索してください。
ディストリビューションを選び、表示される画面で`入手`もしくは`インストール`をクリックするとインストールされます。

![store.png](./images/store.png)

インストール後、`開く`をクリックすると[初回起動](#初回起動)が始まります。

#### 初回起動

インストールに成功すると、Linuxの世界が始まります。
初回起動時に、ユーザー名とパスワードを設定します。
ユーザー名は、Windowsのユーザー名とは関係なく設定できます。
同じでも良いですが、全角文字の使用はお勧めしません。
パスワードにも全角文字を使用しないでください。

```sh
Enter new UNIX username:
New password:
Retype new password:
```

次回以降起動の際は、スタートメニューに`Ubuntu`などの項目が現れるので、それを選択してください（メニュー項目の詳細はインストールしたディストリビューションに依存します）。

#### メモリ使用量制限

たくさんのメモリを搭載したPCでWSLを動かすこともあるでしょう。
大規模な計算では、多くのメモリを必要とすることがあります。
ところが既定値では、WSLが利用できるメモリ量は、PCに搭載されているメモリ量の半分に制限されるようです。

メモリ量は、WSL環境にて以下のコマンドで確認します。

```sh
$ free
               total        used        free      shared  buff/cache   available
Mem:         4014156      410952     3277884        2980      325320     3384068
Swap:        1048576           0     1048576
```

上記例では、WSLで約`4GB`のメモリが利用可能です。

WSLが利用できるメモリ量を変更するためには、設定ファイル
`C:\Users\[ユーザー名]\.wslconfig`
に、以下の記述を追加します。
（ファイルが存在しない場合は、新規作成してください。）

```bash
[wsl2]
memory=8GB
```

（設定を直ちに反映させるためには、`wsl --shutdown`コマンドを実行します。）

例えば64GB搭載したPCでは、50GB程度をWSLに割り当てても良いのではないでしょうか。

ただし、メモリの大部分をWSLが使用すると、Windowsの動作に支障が出る恐れがあります。
WSLが利用するメモリ量を拡大する場合は注意してください。

### Linux開発環境設定

以下の三つのコマンドを実行して、必要なソフトウェア（ライブラリ）を導入します。
コマンド実行時にパスワード入力を求められたら、初回起動時に設定したパスワードを入力します。

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y make gnuplot-x11 gfortran libopenmpi-dev libfftw3-dev liblapack-dev libopenblas-dev evince
```

各コマンドは、ネットワーク環境が良いところで実行してください。
ただし、セキュリティに厳しい組織内で実行すると、ファイヤーウォールで通信が遮断される場合があるそうです。

ここでインストールされるLAPACK, BLASはスレッド並列化されています。
スレッド並列は効果的でない場合が多いので、下記コマンドで無効化すること（`.bashrc`に書き込むこと）をお勧めします。

```sh
export OMP_NUM_THREADS=1
```

Linux上での作業には、テキストエディタを使用します。
標準で`vim`や`nano`はインストールされています。
`Emacs`や`gedit`を使いたい人は、追加インストールしてください。

```sh
sudo apt install -y emacs
```

```sh
sudo apt install -y gedit
```

グラフィック表示を確認します。

```sh
gnuplot
```

```gnuplot
gnuplot> plot sin(x)
```

sin関数が表示されれば、正常に動作しています。

![sin.png](./images/sin.png)

### ファイル共有

WSLは、Windowsとは別の計算機であるかのように振る舞いますが、ファイルを共有するための仕組みが用意されています。

#### WSLから、Windowsのファイルを読み書きする

WindowsのCドライブは、WSLの`/mnt/c`にマウントされます。
例えばWindowsのデスクトップに配置されたファイルは、Cドライブ以下`Users\[ユーザー名]\Desktop\`にあります。
これはWSLからは、`/mnt/c/Users/[ユーザー名]/Desktop/`に見えます。

WSLのホームディレクトリにWindowsデスクトップへのリンクを作成すると、デスクトップを介してのファイル共有に便利です。

```sh
cd
ln -s /mnt/c/Users/[ユーザー名]/Desktop
ls Desktop
```

`[ユーザー名]`は、Windowsのユーザー名です。

#### WSLから、Windowsのエクスプローラーを起動する

WSLから、Windowsのコマンド（*.exe）を実行できます。
Windowsのエクスプローラーを実行するコマンドは、`explorer.exe`です。
同コマンドの引数にディレクトリを与えることができます。

WSLのカレントディレクトリを、Windowsのエクスプローラーで開くコマンドは

```sh
explorer.exe .
```

です。

#### Windowsから、WSLのファイルを読み書きする

Windowsのエクスプローラーのナビゲーションウィンドウ内の`Linux`から、WSLのファイルシステムにアクセスできます。

ディストリビューション名のネットワークドライブアイコン（下図`Ubuntu`）が、WSLのルートディレクトリに相当します。

![Windowsエクスプローラー](./images/winExproler.png)

もしくは、エクスプローラーを起動してアドレスバーに`Linux`（もしくは`\\WSL$`）と入力して表示される`Ubuntu`なども、WSLのルートディレクトリです。

ホームディレクトリ以外のファイルをうかつに操作するとWSL環境を破壊しかねませんので、ご注意ください。

### 端末ソフトウェア

Windows11から、 [Windowsターミナル](https://learn.microsoft.com/ja-jp/windows/terminal/)が標準添付されています。
WSL、Windows PowerShell、コマンドプロンプトのいずれもが、Windowsターミナルで動作します。
Windows10でも、Microsoft Storeから追加インストールして利用できます。

[MobaXterm](https://mobaxterm.mobatek.net)は、端末ソフトウェアとして利用できるのはもちろんのこと、Xサーバーやファイル転送GUIなど豊富な機能を備えており、とても便利です。
有償版（Professional Edition）がありますが、無償枠（Home Edition）でも十分に実用的です。
WSLのみを利用する場合も役立ちますので、ご利用をお勧めします。

![MobaXterm](./images/mobaxterm.png)

## アプリケーションのコンパイル

### PHASE/0

PHASE/0のソースコードを[ダウンロード](https://azuma.nims.go.jp/cms1/downloads/software/)（登録が必要です）し、`phase0_2024.01.tar.gz`をWindowsのデスクトップに配置します。
Ubuntuを起動し、ホームディレクトリにこれらのファイルをコピーします。

```sh
cp /mnt/c/Users/[ユーザー名]/Desktop/phase0_2024.01.tar.gz ~
```

ファイルを伸長します。

```sh
cd
tar xf phase0_2024.01.tar.gz
cd phase0_2024.01
```

`Ubuntu 24.04LTS`を使っている場合は、付属する`Makefile.Linux_generic`でコンパイルする際にオプションを追加してください。

```sh
cd src_phase
F90="mpifort -fallow-argument-mismatch" make -f Makefile.Linux_generic install
```

講習会で利用されることも多い、仕事関数解析プログラム`workfunc`を併せてコンパイルします。

```sh
cd ../src_workfunc
F90="gfortran -fallow-argument-mismatch" make install
```

実行形式ファイル`phase`, `ekcal`, `epsmain`と`workfunc`は、`phase0_2024.01/bin/`ディレクトリにあります。

## 動作検証

続けて、付属サンプル`samples/basic/Si8`で動作を検証します。

```sh
cd ../samples/basic/Si8
```

### PHASE/0：電子状態計算

まず、1コアだけ利用して計算します（非並列）。

```sh
../../../bin/phase
```

ファイル`jobstatus000`（二回目以降の実行では001, 002, ...）に経過時間が出力されます。

```C
 status       =      FINISHED
 iteration    =             15
 iter_ionic   =              1
 iter_elec    =             15
 elapsed_time =       201.3720
```

5行目が経過時間（単位：秒）です。

### PHASE/0：並列計算

次に並列計算をテストします。`-n 2`で2並列で実行することを指示します。WSL1では並列実行時にWarningが出力されますが、計算結果に悪影響はありません。

```sh
mpiexec -n 2 ../../../bin/phase
```

実行時間が概ね半分になっていれば（半分より少し多くて）正常です。物理コア数以上の並列は実行時間の短縮になりません。

## 可視化のためのソフトウェアVESTA

[VESTA](http://jp-minerals.org/vesta/jp/)は、主に固体物理分野において原子配列の表示などに用いられる著名なソフトウェアです。

![VESTA_download](./images/VESTA_download.jpg)

### Windows版インストール

普通のWindowsアプリケーションです。
64bit版の利用をお勧めします。

ダウンロードしたZIPファイルを展開します。

![VESTA_file.png](./images/VESTA_file.png)

### Linux版インストール

WSLgのおかげて、そのまま使えます。
`VESTA-gtk3.tar.bz2`をダウンロードします。

追加ソフトウェアが必要です。

```sh
sudo apt install -y bzip2 libglu1-mesa
```

ダウンロードしたファイルを展開（伸長）して、実行形式ファイルを実行します。

```sh
tar xz VESTA-gtk3.tar.bz2
./VESTA-gtk3/VESTA
```

Xサーバー無しでも動作しますが、（特に、低スペックのPCで）Xサーバーに表示を任せた方が動作が軽快に感じられることがありました。
Windows版は、さらに軽快に動作するように感じます。
WSLgの今後の改良に期待します。

### VESTAによる電荷密度分布の可視化

上記実行サンプルでは電荷密度分布が出力されていますので、それを描画します。
VESTA（Windows版の利用を推奨）を起動して、上部メニューから`Files` - `Open...`を選択します。
表示されるエクスプローラーのナビゲーションウィンドウ（左側のフォルダ階層表示）の`Linux`を起点に、次のようにフォルダを選択していきます。

```cmd
Linux > Ubuntu > home > [ユーザー名] > phase0_2021.02 > samples > basic > Si8
```

選択可能なファイルとして`nfchr.cube`ファイルが表示されますので、これを選択するとVESTAで描画されます。

![chargeSi8half.png](./images/chargeSi8half.png)

この意味にご興味ある方は、PHASE利用講習会や[材料シミュレーションもくもく会](https://m3aterial.connpass.com/)に参加してください。

## 付録A：Windows（WSL Ubuntu）以外の計算機

コンパイラ（C, Fortran）、MPI（並列計算ライブラリ）、FFTW3（高速フーリエ変換ライブラリ）を用意すると何とかなる場合が多いです。
その他 Python3, gnuplot, Emacsなどお好みで追加してください。

### WSLのUbuntu以外のディストリビューション

- オンラインインストール
  - 「wsl -l --online」コマンドで一覧表示されます。
- Microsoft Store
  - Microsoft Storeを起動し、`wsl`で検索してください。
- その他
  - [Project List Using wsldl \| Wsldl official documentation](https://wsldl-pg.github.io/docs/Using-wsldl/#distros)

### Mac

[Mac (Apple Silicon) へのインストール手順](https://github.com/Materials-Science-Software-Consortium/phase0_install/blob/main/Mac_M1/README.md)を参照してください。

[XQuartz](https://www.xquartz.org)は、Macで動作する代表的なXサーバーです。インストールしてください。

Macのターミナルは、UNIX的に利用できます。仮想計算機ではありませんので、`DISPLAY`環境変数を意識する必要はありません。

### Linux：Ubuntu

使わなくなったWindows PCがあれば、Linuxを実機にインストールして利用できます。
[Ubuntu](https://jp.ubuntu.com)はデスクトップ環境での利用を指向したディストリビューションですが、長期サポート（long-term support; LTS）が提供されていることが魅力です。

`apt`コマンドの引数など、WSLと同じように利用できます。

### Linux：Rocky Linux, AlmaLinux

PCクラスターなど常時稼働している科学技術計算用の実機には、Red Hat Enterprise Linux（以下RHELと記す）もしくはその互換OSが利用されることが多いです。
具体的にはCentOSがその筆頭でしたが、CentOS 8は2021年末に、CentOS 7は2024年6月にそれぞれEOLを迎えました。
[Rocky Linux](https://rockylinux.org/)と[AlmaLinux](https://almalinux.org)は2022年以降も引き続き利用可能なRHEL互換OSの有力候補です。

RHEL互換OSでは、`dnf`コマンドでソフトウェア（ライブラリ）を導入します。

```sh
sudo dnf install -y gcc-gfortran openmpi-devel fftw-static perl gnuplot make patch
```

OpenMPI関連のコマンドは`/usr/lib64/openmpi/bin`以下にインストールされます。
環境変数`PATH`を設定してください。

```sh
export PATH=/usr/lib64/openmpi/bin:$PATH
```

Xサーバーは自動的にインストールされ、Xサーバーとクライアントが正真正銘の同一計算機で動作しますので`DISPLAY`環境変数の設定は不要です。

## 付録B：Windowsのアカウント制御

（まとめ）WSLが利用可能になってさえいれば、その他の項目は管理者権限不要の代替手段があります。

### 管理者権限が必要な作業

- WSLが利用可能になるようにWindowsの設定を変更
  - `wsl --update`コマンド実行
- VcXsrvのインストール
- MobaXtermのインストール（インストーラー版；`Program Files`以下にインストールする場合）

### 管理者権限不要

- MobaXtermのインストール（ポータブル版）
- VESTAのインストール
- （WSLが利用可能であることを前提として）Ubuntuをインストールし、それに各種設定を施す。

## 付録C：WSL1とWSL2の相互変換

次のコマンドで、ディストリビューション名とそのバージョンを調べます。

```powershell
> wsl -l -v
```

実行結果は以下のようになります。

```powershell
  NAME            STATE           VERSION
* Ubuntu-20.04    Stopped         2
```

ディストリビューション`Ubuntu-20.04`をWSL1に変換するには、以下のコマンドを実行します。

```powershell
> wsl --set-version Ubuntu-20.04 1
```

ディストリビューション`Ubuntu-20.04`をWSL2に変換するには、以下のコマンドを実行します。

```powershell
> wsl --set-version Ubuntu-20.04 2
```

## 付録D：Xサーバーソフトウェア (Windows向け)

Windows向けの代表的なXサーバーソフトウェアを示します。

- [MobaXterm](https://mobaxterm.mobatek.net)
- [VcXsrv](https://sourceforge.net/projects/vcxsrv/)

[VcXsrv](https://sourceforge.net/projects/vcxsrv/)は、Windows用のXサーバーソフトウェアです。
インストールには管理者権限が必要です。

一方[MobaXterm](https://mobaxterm.mobatek.net)は、Xサーバー付き（他にも盛沢山）の端末ソフトウェアです。
WSLで材料シミュレーションを実行する目的にはオーバースペックですが、第一原理計算を本格活用すると手元のパソコンだけでは計算資源が不足し、他の（大規模な）計算機を利用するようになります。
他の計算機にアクセスする際には、MobaXtermのような端末ソフトウェアが便利です。
MobaXtermには、「インストーラー版」と「ポータブル版」があります。

Windowsの作法に則ってインストールします。Windowsの管理者権限が必要です。

- [VcXsrv](https://sourceforge.net/projects/vcxsrv/)

![vcxsrv.png](./images/vcxsrv.png)

- [MobaXterm](https://mobaxterm.mobatek.net)インストーラー

![mobaX.png](./images/mobaX.png)

- [MobaXterm](https://mobaxterm.mobatek.net)ポータブル版（管理者権限不要）

ZIPファイルをダウンロードし、展開したものをお好きなディレクトリに配置してください。exeファイルをダブルクリックして実行します。

![moba_file.png](./images/moba_file.png)

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

Xサーバー（VcXsrvもしくはMobaXterm）とXクライアント（WSLで動作するUbuntu）を単一のWindows PCで動作させる場合でも、WSLは仮想計算機として、Windowsとは別の計算機であるかのように振る舞います。
また、大規模な計算機を利用する場合も、その計算機（Xクライアント；PCクラスター、スパコンなど）で描画コマンドを発行し、ネットワークを介して、手元のPC（WindowsのXサーバー）で表示させる使い方が一般的です。
その際、Xクライアントに、Xサーバーの画面が（ネットワーク上の）どこにあるのか指示するために、`DISPLAY`環境変数を設定します。

- WSL1の場合

```sh
export DISPLAY=localhost:0
```

WSLから見た`localhost`は、WSL自身です。
一方、XサーバーはWindows PCで動作しているので、辻褄があっていないように感じられますが、これで動作します。

- WSL2の場合

```sh
export DISPLAY=`hostname`.mshome.net:0
```

（参考）Qiita: [WSL2 での DISPLAY 設定](https://qiita.com/taichi-ishitani/items/b627e31a97fef24c6ee4)

hostnameの部分は、コマンド実行結果に置き換えられます。
