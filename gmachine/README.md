# G-Machine

Implementartion of G-Machine based on [this article](https://docs.moonbitlang.com/en/latest/example/gmachine/index.html).

高階関数を何度も入れ子にしていき階層が深くなりすぎるとパフォーマンスの問題が起こる可能性があります。この問題を解決するにはコンパイラーに高階関数を書き換えさせたりする方法もありますが、この問題は遅延評価によっても綺麗に解決するようです。

遅延リスト(Stream)

## Reference

[The G-machine In Detail, or How Lazy Evaluation Works](https://amelia.how/posts/the-gmachine-in-detail.html)
[Constant applicative form from HaskellWiki](https://wiki.haskell.org/Constant_applicative_form)
