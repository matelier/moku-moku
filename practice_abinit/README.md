ABINIT
=

# インストールと初期設定

複数の外部ライブラリに依存していることもあり、ソースからコンパイルする難易度は高めです。
お手軽な方法として、Linuxで、condaを利用したコンパイル済みバイナリの導入を紹介します。
MPI並列にも対応しています。

```sh
$ conda install -c conda-forge abinit
```

サンプル（チュートリアル例題）はインストールされませんので、公式サイトから配布物をダウンロードして展開します。
展開した最上位ディレクトリを`$ABINIT`と記します（例えば`~/abinit-9.6.2`）。

観葉設定用のスクリプトが用意されていますが、使い方がわからないので自分で設定します。

<details>

<summary>`set_abienv.sh`について</summary>

公式ドキュメントには、以下のように環境変数を設定するように書かれています。

```sh
$ source ~$ABINIT/set_abienv.sh
```

しかしながら以下の理由により、これは有効ではないと思います。

- `$0`には実行中のコマンド名に置き換わりますが、`source`で読み込むと（インタラクティブに利用している）シェルの名前に置き換わります。これは意図された動作と異なります。
- `./set_abienv.sh`と**実行**すると、`$0`はコマンド名である`set_abienv.sh`に置き換えられ、（コンソールに出力されるように）意図した環境変数が設定されますが、その環境変数は実行終了と共に消滅し、呼び出し元のシェルには引き継がれません。

</details>

```sh
$ export ABI_HOME=$ABINIT
$ export ABI_TEST=$ABI_HOME/tests/
$ export ABI_PSPDIR=$ABI_TEST/Psps_for_tests/
$ export OMP_NUM_THREADS=1
```

チュートリアル例題は、`$ABINIT/tests/tutorial/Input`にあります。
[公式サイトの説明](https://docs.abinit.org/tutorial/base1/#computing-the-pseudo-total-energy-and-some-associated-quantities)に沿って、その下に`Work`ディレクトリを作成し、入力ファイルをコピーして使います。

```sh
$ cd $ABINIT/tests/tutorial/Input
$ mkdir Work
$ cd Work
```

一つ実行してみます。

```sh
$ cp ../tbase1_1.abi .
$ abinit tbase1_1.abi
```

正常に動作すると`tbase1_1.abo`などのファイルが生成されます。
`tbase1_1.abo`は検証用の実行結果が添付されていますので、比較します。

```sh
$ diff tbase1_1.abo ../../Refs/
```

完全には一致しませんが、よく似た値が出力されていることを確認してください。

[チュートリアル](https://docs.abinit.org/tutorial/)は、説明文（英語ですが）を含めてとても充実しています。
ぜひ取り組んでみてください。
