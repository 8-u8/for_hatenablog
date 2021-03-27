# causalnex trial(Japanese edition)

## はじめに
[英語読めるならココを読んだほうが早い](https://causalnex.readthedocs.io/en/latest/03_tutorial/03_tutorial.html)

## 環境
- OS: Ubuntu 20.14
- python 3.8.5
  - virtural environment: pipenv

## 下準備
### `graphviz`の準備
`causalnex`は`graphviz`を使った可視化を行っているっぽいので、  
素直にインストール。  
`graphviz`についてはなんもわからんので[公式ページみて感じて欲しい](https://graphviz.org/)

```zsh
sudo apt graphviz
sudo apt graphviz-dev
```

どうも`graphviz-dev`がないと[ちょっと困る](https://hytmachineworks.hatenablog.com/entry/2017/01/22/193127)

### `pipenv`での準備
[causalnexのgithub](https://github.com/quantumblacklabs/causalnex)にある通りにしつつ、適宜`pip`を`pipenv`に読み替えてインストール。  
なぜ`pipenv`か？これは信仰上の理由になるので、争うのはやめよう。

```zsh
pipenv install causalnex
```

このタイミングで`pandas`とか`numpy`とか`pygraphviz`とか`matplotlib`とか、  
とにかく`causalnex`で使いそうなやつを入れておく。  
あとは`pipenv shell`で準備完了

## Let us try `causalnex`!
