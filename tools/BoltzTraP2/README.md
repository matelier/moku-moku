# BoltzTraP2

[BoltzTraP2](https://www.tuwien.at/en/tch/tc/theoretical-materials-chemistry/boltztrap2)は、電子状態計算の結果から、ボルツマン方程式を使って輸送係数を求めます。

同一の作者による`2`でない[BoltzTraP](https://www.tuwien.at/en/tch/tc/theoretical-materials-chemistry/boltztrap)が存在します（最終版は`v1.2.5`）。
作者が`BoltzTraP2`の利用を推奨していますので、ここでは扱いません。

## インストール

BoltzTraP2はPythonスクリプト＆モジュールで構成されています。
Anacondaもしくはpipでインストールします。

必要に応じて、Python仮想環境をご利用ください。

### Anaconda (Miniconda)

WSL (Ubuntu-22.04LTS)では、Anaconda (Miniconda)利用が便利です。

```sh
conda install conda-forge::boltztrap2
```

macOSでは、下記`pip`をご利用ください。

### pip

環境に応じて、事前に追加ソフトウェアをインストールします。
その後、`pip`コマンドで`BoltzTrap2`をインストールします。

#### 事前準備：WSL (Ubuntu-22.04LTS)

```sh
sudo apt install g++ python3-dev
```

#### 事前準備：macOS (homebrew)

```sh
brew install gcc
```

#### インストール本番

残りは`pip`コマンドでインストールします。

```sh
pip install numpy
pip install cmake
pip install boltztrap2
```

## 使い方

公式情報
https://gitlab.com/sousaw/BoltzTraP2/-/wikis/home
