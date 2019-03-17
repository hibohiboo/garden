module Page.About exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import Skeleton
import Url
import Url.Builder


view : Skeleton.Details msg
view =
    { title = "このサイトについて"
    , attrs = []
    , kids =
        [ viewHelper
        ]
    }


viewHelper : Html msg
viewHelper =
    div []
        [ Markdown.toHtml [ class "content" ] """
## このサイトについて

### リンクについて

このウェブサイトへのリンクは原則自由です。

### 著作権について

このウェブサイトはhiboが所有・運営しており、これらの著作権はhiboおよび第三者が有しております。

### 利用素材について

このウェブサイトでは以下のサイトから素材を利用させていただいております。
素材の著作権は、各素材の制作者様が有しております。

#### 素材サイト一覧

* [いらすとや](https://www.irasutoya.com/)

#### 素材一覧

* [箱庭のイラスト](https://www.irasutoya.com/2019/01/blog-post_91.html)

### 免責事項

注意を払ってこのウェブサイトを運営管理しておりますが、情報及び動作の正確性、完全性を保証するものではありません。

このウェブサイトを利用したことにより生じるいかなる損害についても、hiboは一切責任を負うものではありません。

また、このウェブサイトの利用に際し、hibo以外の第三者からなされた行為又は提供されたサービスについても、hiboは一切責任を負わないものとします。



        """
        ]
