# PHASE-Viewer

PHASE-Viewerは、PHASE/0利用を支援するGUIです。
ここでは、WSLのUbuntu 24.04LTS環境におけるPHASE-Viewer利用を説明します。

[コマンド操作でPHASE/0を利用できる状態](https://github.com/matelier/moku-moku/blob/master/installation/README.md)を前提とします。

## インストール

PHASE-Viewerの動作には、Java実行環境(JRE)が必要です。
以下コマンドで追加インストールします。

```sh
sudo apt install default-jre
```

Ubuntu 24.04LTSでは、Java 21がインストールされます。

```sh
$ java --version
openjdk 21.0.3 2024-04-16
OpenJDK Runtime Environment (build 21.0.3+9-Ubuntu-1ubuntu1)
OpenJDK 64-Bit Server VM (build 21.0.3+9-Ubuntu-1ubuntu1, mixed mode, sharing)
```

（参考）Ubuntu 22.04LTSでは、Java 11がインストールされます。

```sh
$ java --version
openjdk 11.0.22 2024-01-16
OpenJDK Runtime Environment (build 11.0.22+7-post-Ubuntu-0ubuntu222.04.1)
OpenJDK 64-Bit Server VM (build 11.0.22+7-post-Ubuntu-0ubuntu222.04.1, mixed mode, sharing)
```

PHASE/0付属のスクリプト群は、状態密度図やバンド構造図をEPS形式で生成します。
そしてPHASE-Viewerは、EPSをビットマップ画像に変換して表示します。
その変換にGhostscriptの助けを借りるので、これも追加インストールします。
さらに、PHASE-Viwerの配布物がZIP圧縮されていますので、これを伸長するためのunzipコマンドを併せてインストールします。

```sh
sudo apt install ghostscript unzip
```

PHASE-Viewerの本体は、ダウンロードして入手します。
執筆時点での最新版は、`PHASE-System 2020`の`phase-viewer_2020.zip`です。
ホームディレクトリ直下にて、ZIPファイルを伸長します。

```sh
unzip phase-viewer_2020.zip
```

以上で準備が整いました。
下記コマンドを実行して、PHASE-Viewerを起動します。

```sh
java --add-exports java.base/java.lang=ALL-UNNAMED --add-exports java.desktop/sun.awt=ALL-UNNAMED --add-exports java.desktop/sun.java2d=ALL-UNNAMED -jar ~/phase-viewer/bin/phase-viewer.jar
```

（参考）Ubuntu 22.04LTSなどでJava 11を利用する場合は、`--addo-exports ...`オプション群は不要です。

### 初回起動

初回起動時のみ、下記ウィンドウが表示されます。

![初回起動](./images/initconf.png)

こだわりがなければ、そのまま`ok`を押してください。

- `base directory`: PHASE-Viewerが管理するデータを配置する大元のディレクトリです。既定値はホームディレクトリ直下の`phase-viewer-projects`です。
- `external editor`: テキストエディタを登録します。（後述）
- `ghostscript`: Ghostscriptコマンドを登録します。変更しないでください。

原子配置ビューアが動作することは、実用上とても重要です。
真っ先に確認しましょう。
ウィンドウ左側のディレクトリブラウザから、`samples` - `basic` - `Si8` - `SCF`を選びます（青丸をダブルクリック）。
`input`パネル（橙丸）から、`atomic configuration` - `atomic coordinates`タブ（緑丸）を選択し、`View`ボタン（赤丸）を押すと、原子配置ビューアが起動します。

![パネル](./images/view.png)

![原子配置ビューア](./images/acv.png)

マウス操作で回転、拡大・縮小などできることをお試しください。

原子配置ビューアが正常に動作しない場合は、[MobaXterm](https://mobaxterm.mobatek.net/)からWSLを起動して、MobaXtermのXサーバー利用をお試しください。
改善することがあります。

ここまでできたら、一旦、PHASE-Viewerを終了します。

## 各種設定

PHASE-Viewerを正常に利用するためには、追加設定が必要です。

- PATH
- Host情報
- ジョブコントロールスクリプト

の三つは必須です。
余裕があれば、テキストエディタも設定してください。

### PATH

ここまで[説明通りに実行する](https://github.com/matelier/moku-moku/blob/master/installation/README.md)と、`mpiexec`コマンドにはパスが通っています。
（実行時にコマンド名を与えると、実行ファイルの実体を探す設定ができている、という意味です。）

他方、コンパイル済みPHASE/0ソルバー`phase`, `ekcal`コマンドや、各種スクリプトにはパスが通っていませんので、ターミナルから下記コマンドを実行してパスを通します。

```sh
export PATH=~/phase0_2023.01/bin:$PATH
```

ログインの（新しいターミナルを起動する）度に実行する必要があります。
毎回実行するのは面倒なので、`.bashrc`ファイルに書き込むことを推奨します。

バンド構造図の計算に利用するスクリプト`band_kpoint.pl`と`band.pl`は、パスから探すのではなく、`phase-viwer/bin`ディレクトリに置く必要があります。
コピーします。

```sh
cp ~/phase0_2023.01/bin/band_kpoint.pl ~/phase-viewer/bin
cp ~/phase0_2023.01/bin/band.pl ~/phase-viewer/bin
```

### Host情報

PHASE-Viewerの上部メニューから、`Module` - `configure host info`を選びます。

![Host情報メニュー](./images/confighost.png)

表示されるウィンドウで、`dir`タブを選択して、`bin directory`（赤丸）をPHASE/0コンパイル済みバイナリがあるディレクトリ（`~/phase0_2023.01/bin`）に設定してください。

![ディレクトリ設定](./images/bin2023r.png)

### ジョブコントロールスクリプト修正

`~/.phase-viewer/scripts/jobcontrol`にインストールされるスクリプトファイルの一部は、このままでは利用できません。
[ekcal/submit.sh](./pvscripts/ekcal/submit.sh)と[uvsor-epsilon/submit.sh](./pvscripts/epsmain/submit.sh)を、それぞれリンク先のファイルに置き換えてください。

### テキストエディタ

初回起動時に設定することができるテキストエディタは、後から変更可能です。
PHASE-Viewerの上部メニューから、`Preferences` - `program paths`を選びます。

![外部ツール選択](./images/progpath.png)

表示されるウィンドウで、`external editor`にテキストエディタ起動コマンドを入力してください。

![テキストエディタ選択](./images/externalprog.png)

新規ウィンドウを開くテキストエディタであれば指定できます。
WSL (Ubuntu)から、Windowsアプリケーションをシームレスに呼び出すことができますので、Windowsのテキストエディタも指定できます。

- Emacs（要GUIサポート; emacs-noxは不可）
- vim（要GUIサポート）
- gedit
- メモ帳（Windowsアプリ）
- [Visual Studio Code](https://code.visualstudio.com/)（以下、VS Codeと記す）

などがあります。

WSL (Ubuntu)のターミナルからは、下記コマンドで（Windowsの）メモ帳が起動します。

```sh
notepad.exe
```

上記ウィンドウの`external editor`に`notepad.exe`を指定すると、WSLのPHASE-Viewerから、Windowsのメモ帳が起動します。

VS CodeはWSL (Ubuntu)環境にもインストールできますが、WindowsにインストールしてPHASE-Viewerから呼び出すこともできます。

```sh
code
```

コマンドで、VS Codeが起動します。
PHASE-Viewerの`external editor`にも、`code`を指定します。

（参考）[VS Code設定紹介](https://www.docswell.com/s/matelier/ZQ8VWJ-2024-04-18-105738/6)

## PHASE-Viewerの操作

PHASE-Viewerを利用したPHASE/0計算実習は[コチラ](../practice_phaseViewer/README.md)です。
