## リソース管理

サブシステムとかを初期化する呼び出しをよく行う。

素朴に書くとこのような感じ。

```d
void main()
{
    // 初期化処理
    int ret = SDL_Init(0);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_VIDEO);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_EVENTS);
    assert(ret == 0);

    // 以下ゲームロジックが続く
    //
    // 終了処理
    SDL_QuitSubSystem(SDL_INIT_EVENTS);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_Quit();
}
```

ここで注意しておくべきなのは、assertの中で初期化処理を行わないことだ。リリースビルドの際にassertは取り除かれるので、そのような書き方をすると一緒に初期化処理も取り除かれてしまう。

さて、上の愚直なコードはロジック上の問題があるわけではないが、見通しが悪いという欠点がある。

ここではモジュールコンストラクタ/デストラクタを使って初期化処理を分離していこう。

```d
shared static this()
{
    int ret = SDL_Init(0);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_VIDEO);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_EVENTS);
    assert(ret == 0);
}

shared static ~this()
{
    SDL_QuitSubSystem(SDL_INIT_EVENTS);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_Quit();
}
```

この処理はそれぞれmain関数を実行する前と実行した後に実行される。

`shared static this` はメインスレッドでただ一度実行される。各スレッドごとに初期化処理を行いたい場合は `static this` を使うことができる。

ゲームプログラミングを行う際、パフォーマンスなどの問題によって可能な限りGCを使うことを避けたいという要求がある。その場合でも `pragma(crt_constructor)` を使うことで初期化処理を分離できる。

```d
pragma(crt_constructor)
extern (C) void initialize()
{
    int ret = SDL_Init(0);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_VIDEO);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_EVENTS);
    assert(ret == 0);
}

pragma(crt_destructor)
extern (C) void quit()
{
    SDL_QuitSubSystem(SDL_INIT_EVENTS);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_Quit();
}
```

