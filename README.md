# もくもく材料シミュレーション

原子スケール材料シミュレーションの自習向け資料です。
材料シミュレーションに取り組む「きっかけ」になることを目指します。

## 環境構築（ソフトウェアインストール）

近頃のパソコンは高性能なので、実用的な材料シミュレーションを実施することができます。
ただし電子状態計算の負荷は原子数の三乗に比例することにご注意ください。
計算規模が大きくなると、途端に計算負荷が上昇します。
小さい規模で意味のあるシミュレーションを実施するためには、上手に問題設定する必要があります。
本格的な大規模解析にはスパコンを用います。

原則として、Linux環境のご利用をお勧めします。
Windowsをお使いの場合は、WSL (Windows Subsystem for Linux)の利用により、Linux環境を実現します。

- [WSLの基本的な設定とPHASE/0インストール](./installation/README.md)
- [Rocky LinuxにoneAPIをインストールしてOpenMXをコンパイル](./installation/wsl_rocky_oneapi.md)
- [PHASE-Viewerのインストールと環境設定](./installation/phase-viewer.md)

macOSはそのままUNIX的（≒Linux的）に利用できます。
身近に利用可能なLinux (PCクラスター)があれば、それを使いましょう。

## シミュレーションソフトウェア利用の練習

### PHASE/0

第一原理擬ポテンシャルバンド計算ソフトウェアです。
サンプルが多数付属していますが、各サンプルから重点的に学ぶべきポイントが何なのか、わかりやすい説明が豊富にはあるとは言えません。
これを補うことを意図して、特徴的ないくつかのサンプルについて、[チュートリアル的な解説](./practice_phase0/)を用意しました。

### [ABINIT](https://www.abinit.org/)

計算の原理原則は、PHASE/0と同じです（周期境界条件、平面波基底、擬ポテンシャル）。
PHASE/0に備わっていない解析機能があります。

[ABINITの練習](./practice_abinit/README.md)

<!-- ### OpenMX

局在数値基底を用いています。 -->

### [Elk](https://elk.sourceforge.io/)

全電子計算です。
<!-- 擬ポテンシャルに惑わされずに計算できます。 -->

[Elkをインストール](./practice_elk/README.md)

### AkaiKKR

CPA法と組み合わせて、合金の計算に用いられることが多いです。
計算負荷が軽いので、機械学習の元となる（大量の）データ生成にも役立ちます。

[AkaiKKRの練習](./practice_akaikkr/README.md)

## ツール類

- 電子状態計算結果を解析するツール
  - [Bader電荷解析](./tools/Bader/README.md)
  - [BoltzTraP2](./tools/BoltzTraP2/README.md)
- 入力ファイル作成を支援するツール（主として原子配置）
  - [cif2cell](./tools/cif2cell/README.md)
- 計算実行を支援するツール
  - [pueue](./tools/pueue/README.md)

<!-- ## シェルスクリプト

自動処理をするために、最も簡便な方法。 -->

## 最後に

ご不明な点などあれば、[オンラインもくもく会](https://m3aterial.connpass.com/)でお会いしましょう。
