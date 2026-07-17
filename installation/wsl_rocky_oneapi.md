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
最新版は`10`系列です。`Rocky-10-WSL-Base.latest.x86_64.wsl`
2025年6月の10.0リリースから更新を経て、追加インストールするソフトウェアを含めて整備されています。
ダウンロードしたファイルをダブルクリックすると、自動的に`ターミナル`が起動し、インストールが始まります。
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

`gnuplot`は標準のパッケージ・リポジトリにはありません。
拡張パッケージEPELからインストールします。

```sh
sudo dnf install -y epel-release
sudo dnf install -y --enablerepo=epel gnuplot
```

## oneAPI

Intel社製高性能コンパイラ[Intel oneAPI Toolkits]( https://www.intel.com/content/www/us/en/developer/tools/oneapi/oneapi-toolkit.html)、通称Intelコンパイラです。
（かつて分かれていた`Base Toolkit`と`HPC Toolkit`は、2026.0リリースから`oneAPI Toolkit`に統合されました。）

タブから`Download`を選択し、

- `Packages`から`Intel oneAPI Toolkit`を選択し、
- `Operating System`から`Linux`を選択し、
- `Installer Type`は`YUM/DNF`を選択

すると、右側に説明が表示されます。
`YUM/DNF Prerequisites | Set Up the Repository`をクリックすると詳細手順が表示されます。

まず、リポジトリの設定を行います。
`/etc/yum.repos.d/`ディレクトリの下に、`oneAPI.repo`というファイルを作成します。

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
sudo dnf install intel-oneapi-toolkit
```

インストール終了後、`Configure a YUM/DNF System After Installation`の指示に沿って、下記コマンドを実行します。

```sh
sudo yum update
sudo yum -y install cmake pkgconfig
sudo yum groupinstall "Development Tools"
```

oneAPIのインストール先は`/opt/intel/oneapi/`です。
使用前に、次のコマンドで環境設定します。
`.bashrc`などに追加すると良いでしょう。

```sh
source /opt/intel/oneapi/setvars.sh
```

## OpenMX

最新版`4.0.1`は、`4.0`に対するパッチ形式で配布されています。
以下の二つファイルをダウンロードします。

- [openmx4.0.tar.gz](https://www.openmx-square.org/openmx4.0.tar.gz)
- [patch4.0.1.tar.gz](https://www.openmx-square.org/bugfixed/26May08/patch4.0.1.tar.gz)

パッチの当て方は、[README.txt](https://www.openmx-square.org/bugfixed/26May08/README.txt)の冒頭に詳しい説明があります。

`source`ディレクトリに移動して、`makefile`を以下のように修正します。

```diff
--- makefile.org        2026-04-26 08:16:00.000000000 +0900
+++ makefile    2026-07-17 18:08:41.877988404 +0900
@@ -5,9 +5,9 @@
 #                                                                 #
 ###################################################################

-MKLROOT = /opt/intel/oneapi/mkl/2025.3
-CC = mpiicx -O3 -xHOST -fcommon -Wno-implicit-function-declaration -ipo -qopenmp -I${MKLROOT}/include -I${MKLROOT}/include/fftw
-FC = mpiifx -O3 -xHOST -qopenmp -ipo
+# MKLROOT = /opt/intel/oneapi/mkl/2025.3
+CC = mpiicx -O3 -fcommon -Wno-implicit-function-declaration -ipo -qopenmp -I${MKLROOT}/include -I${MKLROOT}/include/fftw
+FC = mpiifx -O3 -qopenmp -ipo
 LIB= -L${MKLROOT}/lib/intel64 -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -lifcore -lmkl_blacs_intelmpi_lp64 -liomp5 -lpthread -lm -ldl
```

`MKLROOT`は、oneAPIの環境設定の一部として自動的に設定されます。

`make`コマンドでコンパイルします。

```sh
make install
```

実行形式ファイル`openmx`は`work`ディレクトリにコピーされます。

### コンパイルオプションについての補足

`OpenMX`に標準添付の`makefile`では、オプション`-xHOST`が指定されていましたが、上記修正では削除しました。
同オプションを指定すると、生成される実行形式ファイル`openmx`が実行できない（AMDのCPUを搭載した計算機で、下記メッセージを出力して直ちに終了する）場合があったためです。

```sh
This executable is built with target processor feature specified, it can only be run on Intel(R) processors.
```

`-xHOST`は最適化に関するオプションですので、計算結果には影響を及ぼしません。
動作するのであれば、同オプション付きでコンパイルするのも良いと思います。