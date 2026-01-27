# WSLで動くRocky LinuxにoneAPIをインストール

## 概要

WSL上で動作するLinuxディストリビューションは、オンラインインストールやMicrosoftストアから入手できるものだけではありません。
ここでは[Rocky Linux](https://rockylinux.org/)をインストールする手順を説明します。

さらに、高性能開発環境としてoneAPIをインストールし、それを利用して材料シミュレーション用のアプリケーションソフトウェア[OpenMX](http://www.openmx-square.org/)をコンパイルするまで、を説明します。

WSL環境は構築済みとして説明します。
未完了の方は例えば[こちら](./README.md)を参照してください。

## Rocky Linux

RedHat Enterprise Linux (RHEL)互換ディストリビューションとして、長らく[CentOS](https://www.centos.org/)が君臨してきましたが、最新のStreamは、もはや我々が期待する互換ディストリビューション（ダウンストリーム）ではありません。
新たに複数のRHEL互換ディストリビューションが立ち上げられた中、**Rocky Linux**は、[AlmaLinux](https://almalinux.org/ja/)と共にその中心的な役割を担うことが期待されています。

公式サイト[Download](https://rockylinux.org/ja-JP/download)から、WSL用のイメージをダウンロードします。
最新版は`10`系列ですが、追加インストールするソフトウェアの整備状況を考慮して、`9`系列の利用をおすすめします。`Rocky-9-WSL-Base.latest.x86_64.wsl`
それをダブルクリックすると、自動的に`ターミナル`が起動し、インストールが始まります。
ユーザー名の入力を促されるので、入力してください。

```sh
Enter new UNIX username:
```

メッセージが表示されます。

```
Your user has been created, is included in the wheel group, and can use sudo without a password.
To set a password for your user, run 'sudo passwd matelier'
```

大雑把に言えば、以下の意味です。（一行目のみ）

    作られたユーザーは管理者グループ(`wheel`)に追加されたので、パスワードなしに`sudo`実行できます。

以上でインストール完了です。

最初に各種ソフトウェアをアップデートすることをお勧めします。
（早速`sudo`コマンドが登場します。）

```sh
sudo dnf update -y
```

二回目以降の起動は、「ターミナル」を使います。
スタートメニューから選択して「ターミナル」を起動します。
ウィンドウ上部のタブの左の「v」をクリックして、プルダウンメニューから「rocky」を選択します。

追加ソフトウェアをインストールします。

```sh
sudo dnf install -y gcc-c++ make xauth perl
```

`gnuplot`は標準のパッケージ・リポジトリにはありません。
拡張パッケージEPELからインストールします。

```sh
sudo dnf install -y epel-release
sudo dnf install -y --enablerepo=epel gnuplot
```

## oneAPI

Intel社製高性能コンパイラ[Intel oneAPI Toolkits](https://www.intel.com/content/www/us/en/developer/articles/news/free-intel-software-developer-tools.html)、通称Intelコンパイラです。
[Base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit.html)と[HPC Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/hpc-toolkit.html)をそれぞれインストールします。

各ツールキットのページから、`Download the Tooolkit`を選択し、

- `Operating System`から`Linux`を選択し、
- `Installer Type`は`YUM or Zypper` (HPC Toolkitでは`YUM/DNF`)を選択

すると、右側に説明が表示されます。
`YUM/DNF Prerequisites | Set Up the Repository`をクリックすると詳細手順が表示されます。

まず、リポジトリの設定を行います。
両ツールキット共通の操作です。
`/etc/yum.repos.d`ディレクトリの下に、`oneAPI.repo`というファイルを作成します。

```
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
```

設定が完了すると、パッケージ管理コマンドでインストールできます。

```sh
sudo dnf install intel-oneapi-base-toolkit
sudo dnf install intel-oneapi-hpc-toolkit
```

インストール先は`/opt/intel/oneapi/`です。
次のコマンドで環境設定して利用します。
`.bashrc`などに追加すると良いでしょう。

```sh
source /opt/intel/oneapi/setvars.sh
```

## OpenMX

最新版`3.9.9`は、`3.9`に対するパッチ形式で配布されています。
以下の二つファイルをダウンロードします。

- [openmx3.9.tar.gz](https://www.openmx-square.org/openmx3.9.tar.gz)
- [patch3.9.9.tar.gz](https://www.openmx-square.org/bugfixed/21Oct17/patch3.9.9.tar.gz)

パッチの当て方は、[README.txt](https://www.openmx-square.org/bugfixed/21Oct17/README.txt)の冒頭に詳しい説明があります。

`source`ディレクトリに移動して、`makefile`を以下のように修正します。

```diff
--- makefile.org 2024-08-17 13:21:23.964546682 +0900
+++ makefile 2024-08-17 13:21:41.424545221 +0900
@@ -5,10 +5,10 @@
 #                                                                 #
 ###################################################################

-MKLROOT = /opt/intel/mkl
-CC = mpicc -O3 -xHOST -ip -no-prec-div -qopenmp -I/opt/intel/mkl/include/fftw
-FC = mpif90 -O3 -xHOST -ip -no-prec-div -qopenmp
-LIB= -L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -lmkl_blacs_openmpi_lp64 -lmpi_usempif08 -lmpi_usempi_ignore_tkr -lmpi_mpifh -liomp5 -lpthread -lm -ldl
+MKLROOT = /opt/intel/oneapi/mkl/latest
+CC = mpiicx -O3 -qopenmp -fcommon -I${MKLROOT}/include/fftw -Wno-error=implicit-function-declaration
+FC = mpiifx -O3 -no-prec-div -qopenmp
+LIB= -L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -lmkl_blacs_intelmpi_lp64 -lifcore -liomp5 -lpthread -lm -ldl


 #
```

`make`コマンドでコンパイルします。

```sh
make install
```

実行形式ファイル`openmx`は`work`ディレクトリにコピーされます。

### コンパイルオプションについての補足

`OpenMX`に標準添付の`makefile`では、オプション`-xHOST`が指定されていましたが、上記修正では削除しました。
同オプションを指定すると、生成される実行形式ファイル`openmx`が実行できない（下記メッセージを出力して直ちに終了する）場合があったためです。

```sh
Please verify that both the operating system and the processor support Intel(R) X87, CMOV, MMX, SSE, SSE2, SSE3, SSSE3, SSE4_1, SSE4_2, MOVBE, POPCNT, AVX, F16C, FMA, BMI, LZCNT, AVX2, AVX512F, AVX512DQ, ADX, AVX512CD, AVX512BW, AVX512VL, AVX512VBMI, AVX512_VPOPCNTDQ, AVX512_BITALG, AVX512_VBMI2, AVX512_VNNI and SHSTK instructions.
```

`-xHOST`は最適化に関するオプションですので、計算結果には影響を及ぼしません。
動作するのであれば、同オプション付きでコンパイルするのも良いと思います。

- 動作しなかった環境の例
  - AMD Ryzen9 7900X
  - Rocky Linux 9.4
  - Windows 11で動作するWSL2
  - oneAPI 2024.2
