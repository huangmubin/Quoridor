####--  关于这个桌游 --

开始之前先介绍一下要开发的这个游戏，它叫Quoridor。如果你是一个深度桌游爱好者，那你可能会知道它的中文版本——步步为营/围追堵截。

先上一下它美美的剧照。
![Quoridor](http://upload-images.jianshu.io/upload_images/721097-da8581f00da1e33b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Quoridor规则非常简单，一个人有一个棋子，十块木板。轮流下棋，每次轮到你呢就可以选择移动你的棋子或者放置一块木板到棋盘中。
棋子的移动上下左右，而且不能跳过木板阻隔的位置。当有对手在你身边的时候，你可以借助他从而走多一步。
木板可以任意放置，但是，必须给对手至少留下一条活路。

但是，越简单，越不简单。反正，从第一次玩这个游戏，我就彻底迷上了。那时候，我还不会iOS开发呢，就对自己说，我以后，要把这游戏，实现到手机上去。

####-- 关于这个游戏 --

地址先奉上。[Github-Quoridor](https://github.com/huangmubin/Quoridor)
当然，我并不是第一个把这个游戏实现的人。甚至，我不是第一个在iOS平台上实现这个游戏人。就我所搜索到的，这个游戏有Java版本，C++版本，Javascript版本。
不过，倒霉的事情是，我没有能让我下载到的任何一个版本成功运行起来。(T-T)天啦撸，这是何等的悲伤。加之我对以上三种语言都是处在勉强能阅读的程度，对于整个程序，Hold不住呀。(本来找到C++版本好开心的，然而里面用了好多我连搜索都搜索不出来是什么意思的语句，就……跪了。)
所以，只好全盘自己写了。

当然在开始之前，我需要先说明，我也只能算一个小白。所以如果你觉得我代码写得一塌糊涂。我十分热烈的欢迎你对我鄙视然后写一个牛逼的版本让我拜读，我将感激不尽。

####-- 游戏UI --
为了能让我后面开发起来有的放矢，知道自己在写什么，所以我习惯先画个UI出来。
我用Sketch，画了一个很简单的界面。
![屏幕快照 2016-01-09 下午11.46.07.png](http://upload-images.jianshu.io/upload_images/721097-4a9333628e3416dd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如大家所见，就是中间棋盘，两边一个悔棋，一个重新开始，还有木板数量，到达步数。简简单单的游戏界面就这样出来了。
我承认这并不好看，我也承认这设计有点屎，但是！我会努力的。欢迎提建议。

####-- 游戏结构 --
先丢上游戏的程序结构。
![屏幕快照 2016-01-09 下午11.53.58.png](http://upload-images.jianshu.io/upload_images/721097-2add286bc56697aa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没错，这是一个经典的MVC设计模式。
毕竟游戏结构很简单，我们没必要把它复杂化。

####-- 开始构建游戏 --

我喜欢从UI开始构建一个应用，而且我喜欢用Storyboard。（曾几何时，我一直觉得纯代码构建整个应用才是最酷的，但是当我对一个应用的UI进行了几次改动后，我就体会到这种酷是有代价的。）
所以，上UI截图。

![屏幕快照 2016-01-10 上午12.09.40.png](http://upload-images.jianshu.io/upload_images/721097-7eed6fbfa8eb4cef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

纳尼！一片空白，啪！回水！
冷静冷静，注意看，其实这个UI界面还是有很多视图的。只不过我都把他们的颜色给选择clearColor了。原因也很简单，我需要圆角，而最简单的实现圆角的办法就是用代码修改UIView的Layer。而且这样做的好处也很多，比如，我可以很容易的就进行主题颜色的切换。

我先放个大图然后后面讲我的思路。

![屏幕快照 2016-01-10 上午12.23.04.png](http://upload-images.jianshu.io/upload_images/721097-759359202b8cc731.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


0.首先游戏由三个部分组成。
棋盘；
Top控制面板；
Down控制面板；

每个控制面板中四个按钮。
于是Center、Top、Down Background确定。

它们都由一个Background类，来绘制一个边框以及一个圆角。

1.由于游戏要显示当前轮到谁了，我的做法比较粗暴，就是轮到你，才显示你的控制面板。否则就把它盖起来。
于是又多了两个视图，Top、Down Screen。它们跟Top、Down Background完全对齐。
作用就是轮到你时，就隐藏起来，让你可以看到自己的控制面板，否则就显示出来，当个马赛克。

它们都由Screen类控制，以显示对应内容还有显示消失等控制时的动画。

2.游戏棋盘是Chess Board。
由ChessBoard控制，其实也很简单，就是画9*9个小格子。
它跟Center Background对齐，但是比它小10个像素。
至于为什么不把它放在Center Background里面呢，因为……我不喜欢。

3.Chess Wall层的工作是绘制当前的墙壁。

4.Player Prompt层是用来在你提起棋子时显示当前可以移动的位置的图层。

5.Chess Player层就是绘制棋子的图层啦，里面有两个Layer，各自表示一方棋子。由于各种原因，这个游戏只能两个人玩。

6.Wall Prompt，顾名思义，就是要放置墙壁时用来提示墙壁位置的。它会在墙壁到不可放置时变成红色。

7.Touch View，这就是用来接收玩家触摸位置信息的图层。上面说到的所有的类都是属于Views当中的类。唯有TouchView我是把它放在Controllers当中的。因为在我看来，它的角色就是一个控制器。实际上，它也不显示任何东西，只是单纯的接收触摸位置，然后进行简单的分析之后，通过Delegate设计模式将触摸事件反馈给GameController。
当然，你要说这是一个View也是对的。

8.EndScreen。这是用来显示游戏结束动画的图层。

好啦。至此，整个游戏的UI我们就构建好了。请原谅我只是介绍了一下每个图层的作用。因为对应的代码你都可以找到。而且我在当中也有相应的注释。并且每个类也都让我用各种MARK把一个个功能划分开来。如果你有不明白的地方，也欢迎来吐槽一下。

####-- 构建游戏模型 --


![屏幕快照 2016-01-10 上午12.52.36.png](http://upload-images.jianshu.io/upload_images/721097-7ad15b981a1d5b89.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

游戏的Models一共有五个文件，但是其实只有3个类。
我不想让GameModel看起来太过臃肿，就用了扩展把它区分成几个文件，希望能让他看起来更加清晰一点。

从最基础的部分说吧。

-- DataModel --

顾名思义，这就是整个游戏最基础的数据结构。
用他可以来表示棋子，木板两种元素。
主要内容无比简单，就是：
```
// MARK: - Data
    /* 数据具体坐标和类型 */
    
    /** x轴坐标 */
    var x: Int { didSet { updateId() } }
    /** y轴坐标 */
    var y: Int { didSet { updateId() } }
    /** Horizontal: 如果是木板，则表示横向horizontal与竖向vertical。如果是棋子，则表示顶方Top与下方Down。 */
    var h: Bool {
        didSet {
            if t {
                updateWallIds()
            }
        }
    }
    /** Type: 类型，True表示木板，False表示棋子。 */
    var t: Bool
```
我还给他写了另外两个属性，用来方便计算游戏逻辑以及Ai的时候使用。你可以注意到，这里我没有使用计算属性，而是利用属性监视器在XY坐标改变时更新它们。因为，我觉得，比起变更坐标。调用辅助属性的次数会更多，如果每次调用都进行计算，无疑是会比较消耗CPU的。加上，这也耗不了多少内存，所以就这样做了。
原谅我对CPU占用如此敏感，因为我第一个Ai计算一步棋需要四分钟，所以……我……
```
    // MARK: Count Data
    /* 不进行存储的辅助数据 */
    
    /** 棋子坐标 */
    var id: Int = 0
    
    /** 墙壁坐标 */
    var wallIds: [Int] = [Int]()
```
此外，我还给他写了一些Copy方法，还有转换方法，都是为了调用方便。有兴趣你可以看看。

-- GameModel --

这部分就是真正的重头了。
这个类第一部分是Interface。这是我为了方便自己进行调用而写的函数。我觉得这样做其实挺违背Swift的初衷的，毕竟它把接口文件都取消了，我还自己写了一个接口部分。但是我觉得这样做，能让我在各个对象之间调用的时候思路更加清晰。
每一个类都专注做自己的事情，就好像一个人一样，并且有特定的与其他类进行交互的内容。这样我觉得很好。至少我是这样理解面向对象开发的——程序的本质是各种对象协作方式的体现。（自言自语，如有雷同，我深感荣幸。）

这是一个单例类，游戏模型嘛，你懂的。
```
    // MARK: - Singleton Class
    /* 创建游戏模型的单例类，并禁止其他类初始化该方法 */
    
    /** 游戏模型的单例 */
    static var shared = GameModel()
    
    /** 私有化初始化方法 */
    private override init() {
        super.init()
        initModelData()
    }
```

各个接口的意义我都有注释，所以大家看看就好。
主要的内容包括了这么些部分：

0.控制游戏主题颜色的变量
```
// MARK: 色彩方案
    /** Color Model */
    var color: Bool = true
```

1.代表当前游戏的玩家数据信息
```
    // MARK: 玩家数据
    /** Top Player Data */
    var topPlayer: DataModel  = DataModel()
    /** Down Player Data */
    var downPlayer: DataModel = DataModel()
    
    /** Top Walls Data */
    var topWalls: [DataModel]  = [DataModel]()
    /** Down Walls Data */
    var downWalls: [DataModel] = [DataModel]()
    
    /** All walls data */
    var allWalls: [DataModel] { return topWalls + downWalls }
    
    /** Ai is open */
    var gameAi: Bool = true
```

2.棋谱数据，悔棋的时候会用到。也可以保存游戏数据，但是由于一盘棋很短，所以我暂时没有做保存的功能。感觉需求不大。
```
    // MARK: 棋谱
    /** Chess manual Stack */
    var gameStack: [DataModel] = [DataModel]()
```

3.游戏数据。
包括当前轮到哪个玩家。游戏的状态，是谁赢了。还是依旧在进行中。实际上这个游戏是有平局的。但是目前还没有体现。计算方式非常普通，稍微看看代码就可以明白的。
```
    // MARK: 游戏数据
    /** The current player */
    var player: Bool {...}
    
    /** The game state */
    var status: GameStatus {...}
```

还有很重要的两个数据。
棋盘通道记录，我把每一个棋盘的小方块用0-80共81个数子来表示，然后记录每一个点可以行走的下一步的范围。
墙壁数据。我把棋盘从9x9.加上墙壁的槽，变成了17x17的大棋盘。每一个墙壁都会占据三个点。这样就可以防止出现墙壁交叉的情况。
这两个数据的存在依然是为了以空间换时间。我对于Ai部分有深深的恐惧感，为了能够更快的计算出合适的棋步。只好这样了。
```
    /** 棋盘通道记录 */
    var gameNears: [[Int]] = [[Int]]()
    
    /** 墙壁数据记录 */
    var gameWalls: [Bool] = [Bool]()
```
老样子，看图说话：


![屏幕快照 2016-01-10 上午10.31.05.png](http://upload-images.jianshu.io/upload_images/721097-bb5e03131a77c720.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![屏幕快照 2016-01-10 上午10.31.31.png](http://upload-images.jianshu.io/upload_images/721097-fc65b365dd4f6763.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



GameModel+Action 文件基本上是对游戏接口函数的实现。假如在以后有什么游戏操作行为的函数，都会放到这其中。
GameModel+Logic 是一个计算当前棋子的可移动距离的函数。以后有需要计算的逻辑类型的内容也都会在这里面。

-- GameAi --

恩。这个，故名思议，游戏的Ai是这个文件计算出来的。……我放到最后面才说游戏Ai部分，因为它是我最后实现的。同时，它也是到现在都一直不断在改进的地方。

####-- Controller --

![屏幕快照 2016-01-10 上午10.33.46.png](http://upload-images.jianshu.io/upload_images/721097-443b45386b3a6177.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

一共就三个文件。

FrameCalculator文件是一个坐标计算器，是为了给View他们使用的时候考虑一些偏移之类的情况。我统一把这部分的计算函数放在一个新的类里。由于，这部分本来应该是Controller的东西，所以放在这个目录之下。
（到这里，可能要有人说，我已经把MVC设计模式丢到某个不知名的星球上去了。确实我承认这一部分我做得不是很严谨，但是，我认为MVC设计模式的精髓是让我们区分好整个程序的功能架构。分成三个部分，一部分管理数据，一部分管理视图，一部分协调数据与视图之间的关系。所以，我认为，只要能让别人一眼看出来，我哪些文件是负责哪一块功能，并且文件之间的关系是怎么样的，那就足够了。毕竟，后来新兴起的各种设计模式，也都是在MVC的基础上发展而来的，无非，就是把各个模块进行细分罢了。目的，也就是一个，清晰思路。）

TouchView就是一个接收器，前面提到过了。

GameController是一个正儿八经的控制器。打开它的索引，你可以看到，尽管我已经将它的很多功能都切出去了。但是依然很长很长。
![屏幕快照 2016-01-10 上午10.42.09.png](http://upload-images.jianshu.io/upload_images/721097-028ffd9e5e14e30e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们一点点来。

-- Controller Life Cycle --

这个很好理解，就是生命周期的控制。而这里关键就是一些初始化配置。你可以看到，这里我就是调用一个个函数，而不是直接进行各个控件之间的设置。
这个是我的一个习惯，不知道算好还是算坏。

我喜欢用MARK吧各个功能模块划分出来。
比如下一个GameLogic模块，就是控制了游戏逻辑的代码。
再下一个Buttons。这个模块中可以找到所有的按钮初始化函数，按钮事件反馈。
每个模块我都将它当成一个独立小对象来对待。这样的划分让我可以非常直观的立刻查询到我所想要的内容。而且，极大的减少了我更改某一个功能模块的代码时，对其他模块的影响。
```
// MARK: Init Game
    
    /** 初始化游戏启动配置。 */
    private func gameLaunch() {
        initDemonstrationView()
        initSound()
    }
    
    /** 更新游戏显示内容 */
    private func gameAppear() {
        alignmentButtons()
        updateButtonsTitle()
        updateGameColor()
        initTouchView()
        updateScreen()
        chessPlayer.update(true)
        chessPlayer.update(false)
    }
```

那么，按照我的这种逻辑。
整个控制器其实就很简单了。
它的功能实现主要就是通过实现TouchViewDelegate的函数，接收到触摸事件后，将触摸点分发给对应的视图，让他们做出反馈。
当触摸结束时，判断是否一次合理的操作。不是就直接结束操作。
是的话就更新GameModel数据。
然后调用Game Logic当中的changePlayer函数。
changPlayer函数负责更新视图，并且判断游戏是不是结束了。
是不是下一步要计算机来下棋了。

####-- 说回GameAi --

好了。终于，回到这个话题了。其实我写了这么长的篇幅，我就想跟大家聊聊这个。
因为……臣妾真的做不到！！！

-- 0.0版 --

棋盘类游戏的Ai，相信很多会立马想到，做一个博弈树，然后根据阿法贝塔剪枝技术进行优化。所以，很简单啊。
我一开始也是这么的觉得的，于是我以广度优先算法计算出最短路径，然后以最短路径以及木板数量作为评估方式。
Ai开始计算的时候，直接罗列出所有可能的落子范围，对每一个点进行评估，计算出最大值，然后对最大值进行下一层评估，获取最小值。（极大极小算法）
中规中矩但是非常实用。一开始我只让他计算两层，即已方下一步，对方下一步。而且，由于我知道这游戏不能简单的极大极小，最短路径很可能是对方给你留下的坑，所以我放弃了剪枝。
于是，我愉快的开始游戏了。
然后，等了4分钟，它终于动了。好极了，Xcode上显示Cpu占用100%4分钟，如果我用的是手机，那这时候鸡蛋都熟了。

于是我仔细查看了一下层序，发现，逻辑没有任何错误。错就错在，每一步棋，需要计算的可能解是132个，计算两步就是132个132次方。天啦撸……而且由于每次计算都要考虑是否封死对方的路径，就是需要进行两次广度优先计算。而且在当时棋子可能解，墙壁可能解这些我还都是直接每次都进行运算得出的，没有用空间换时间。所以……

虽然剪枝后会好点，但是说实话，剪枝后基本上跟瞎下也没有太大差别……

怎么办呢？
蒙特卡罗算法？
遗传算法？
蚁群算法？
大数据？

-- 1.0版 --

我仔细的考虑过后，感觉，问题应该出在局面上。
因为很多位置的墙壁是可以不需要考虑的。
而且，不管是什么样的算法，如果我没有办法给出一个高效而且具有实际意义的局面评分，那都无法算出有效的棋路。
于是，我这一次Ai的改进集中在棋局评估上。

然后我想到，为什么不直接阻挡对方的最短路径呢？

所以，这一次Ai总算靠谱点了，只对对方的最短路径进行运行。查找能够最让对方恶心却又不影响自己的最短路径的一个位置放木板。（也就是，计算木板对对方最短路径的影响。取影响最大的那一块。）玩起来已经有在下棋的感觉了。

然后我做了一个开局函数，让它前几步都是随机放置的，而到了中期就根据前面的随机木板进行运算，从而达到不会说一直重复一个下法的效果。

加上我改进数据结构，空间换时间，空间换时间，空间换时间。好极了。快到一瞬间的事情。

然而，这家伙只会恶心对方，却完全不可能赢呀。因为它会傻傻的把所有木板一次性放置进去。但是就我对这游戏的理解，木板就好像核武器，你哪怕留着一块对对方都是一个威胁。在开局被对方堵到吐血，等对方用光木板后把它当猪一样杀是非常简单的事情。
然而，这个版本的Ai就是那头猪。

-- 2.0版 --

我觉得我应该考虑一下出现多路径的情况。
就是当计算机知道自己现在有两条路，一条可以五六步到达终点，另一条是十多步到达的时候，它应该有意识地去切断自己的长路径，从而进行防守。
这是每个正常玩家都可以想到的事情。

那么，如何计算出来多路径呢？

翻遍了算法书，我也没有找到可以现成使用的算法……当然，也可能是我翻的书不够多，如果我翻到了，我回来自己扇自己脸。

要知道，我要计算多路径，是计算每一个可能解的最短路径。中间不能在棋盘上乱绕。所以如何让他在遇到分叉路口的时候会自动产生分支呢？

-- 2.1版 --

我在看到不少拓扑排序的应用后，忽然感觉有个灵感……（看完别问我这跟拓扑排序有什么关系，我也不知道，但是我就是这样来灵感的。）

我可以在广度优先算法的计算上，每次进行扩展时，对扩展出来的点进行分析，如果他们是相邻的，则放在一个集合中。如果他们不相邻，这产生多个集合。
然后，每个新的集合都会变成一个新的分支，然后进行迭代处理就可以查到到所有的路径了。

示意图如下，以46号点作为棋子的位置。
第一次扩展会扩展出来37，45，55号点得位置。他们都是相邻的。
第二次则是56，64，54 以及 36，28五个点。我们可以明显的看到他们并不相邻。于是，进行分支。如表格1-1与1-1-1.
其中1-1.在进行了又一次扩展后，找到了重点位置，于是返回最短路径。
1-1-1.则继续运行，并且在上方会又产生新的分支。
![屏幕快照 2016-01-10 上午11.24.23.png](http://upload-images.jianshu.io/upload_images/721097-c9f13ded21fb105a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最终产生这样的路径图谱。

![屏幕快照 2016-01-10 上午11.27.52.png](http://upload-images.jianshu.io/upload_images/721097-b0647c96594ff9e3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我一看乐了。多路径有了，连路径宽度都有了。当时有种走上人生巅峰的感觉。
于是，我赶紧实现这个算法。

然而……实际测试中，这样出现的问题还真不小……我每次进行分支都会继承上一个分支所查询过的点，而由于这个点是斜方向扩展的，很可能会把一些回路给遮挡掉。导致本来有多个路径，结果计算出来只有1个路径。


截止到目前，我还在往这个方向努力中。其实写了这篇文章主要的目的有两个，一个是理清我自己的思路。另一个是希望能有更多对这个游戏感兴趣的朋友一起来改进它。我相信有更多的人进行思想碰撞后，肯定可以得到更多更棒的想法。

第一个目的我达成了，因为写到这里，我已经多出来了很多想法，包括如何改进多路径查询。然后利用这样的局面评分做到准确的判定。以及如何利用棋局记录来做一个学习型的Ai。

第二个目的就看你的了。棋盘摆好了，我们来下一局？

对了，我真不是标题党，这个应用我已经申请上架了。审核中~当然，这是免费的游戏。因为作为一款游戏，它欠缺趣味性，欠缺美感，欠缺各种各种……但是，作为一个应用，它让我学习到了好多东西。

欢迎各位吐槽，同时，也希望大家能来碰撞一下。我还在学习，也在学习如何学习。希望大家能指点一二。
