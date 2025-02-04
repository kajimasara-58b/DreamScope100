# DreamScope100


■サービス概要  
人生で達成したい100のことを気軽に記録し、達成状況を可視化するアプリです。
やりたいことをしないままで終わらせないために、各ユーザーの目標をシンプルに管理します。
ただのメモやリストとしてではなく、愛着を持って使えるような仕組みを持たせます。


■ このサービスへの思い・作りたい理由
自分の夢を文字に起こし、実現する過程を見える化することで、各ユーザーの人生をより豊かにしたいと考えました。
生きていると毎日をなんとなく過ごしてしまいがちですが、人生でやりたいことをすべて達成するにはその目標を日々意識して過ごす必要があります。
大きな目標は先延ばしにしてしまいがちですし、小さな目標も今でなくていいかと後回しにしてタイミングを逃してしまいがちです。
（仮称）DreamScope100が、ユーザーのやりたいことや目標を達成するきっかけになって欲しいと思います。
 
  
■ ユーザー層について  
・達成したい夢や目標がある人  
・これから夢や目標を見つけたい人
・日々をなんとなく過ごしてしまいがちな人  
  
  
■サービスの利用イメージ  
100個まで自由に、達成したいこと・いつまでに達成したいのかを記録する。
達成した際はチェックマークをつけるなどで記録し、100個のうち何個達成しているか一目でわかるように表示する。
 
  
■ ユーザーの獲得について  
SNS共有機能により、目標の共有や達成報告を可能に
記録・達成した夢や達成率を共有できるコミュニティ機能を検討
 
  
■ サービスの差別化ポイント・推しポイント  
【競合アプリ】
・Bucket List Apps や Notion での目標管理
・Habitica のようなゲーム型のハビット管理
    
【差別化ポイント】  
・ただのリストにとどまらず、達成状況にフォーカスして夢を達成していきたいと思わせる仕組み
・「人生で達成したい100のこと」に特化したシンプルで分かりやすいUI
・やりたいことをカテゴリ分けすることで、達成目標日だけでなくカテゴリ別でも並び替えができる（本リリース予定）
・他ユーザーとのオープンチャット機能で、目標を立てるときの宣言や、達成時の喜び報告ができる（本リリース予定）

  
■ 機能候補
【MVPリリース】
・ユーザー新規登録、ログイン、ログアウト
・100の目標作成、編集、削除
・達成した際の記録
・達成状況を%でトップページに表示

【本リリース】
・目標のカテゴリ設定機能
・一覧画面での並び替え機能
・オープンチャット機能
・カレンダー連携機能
・「達成目標日　●日前」をお知らせする通知機能
・SNSシェア機能


■ 機能の実装方針予定  
【開発環境】  
　Docker  
　VSCode  
  
【サーバサイド】  
　Ruby on Rails 7系  
　Ruby 3.2.2  
　Rails 7.0.4.3  
  
【フロントエンド】  
　Hotwire, Stimulus.js  
  
【CSSフレームワーク】  
　Bootstrap 5  
   
【インフラ】  
　Webアプリケーションサーバ: Fly.io   
　ファイルサーバ: AWS S3  
　セッションサーバ: Redis by Upstash  
　データベースサーバ: PostgreSQL  
  
【チャット機能】  
　WebSocket, ActionCable  
  
【ユーザー認証機能】  
　Devise  
  
【その他】  
　VCS: GitHub  
　CI/CD: GitHubActions  
