# botapeer-infra
botapeerのインフラリポジトリです。AWSで構築され、terraformでコード管理されています。

## APIのネットワーク構築図
全体的にはこのように構成されています。
![スクリーンショット 2023-04-07 21 11 14](https://user-images.githubusercontent.com/39892315/230606629-4bf6f5e6-416d-453b-ba5b-bf6e41eed254.png)

### 構成の説明
- S3
  - terraformの状態管理するterraform.tfstateはS3で管理しています。
  - プロフィール画像や投稿された画像をアップロードするためにも利用されます

- ECS FagateとECR
  - バックエンドであるspringフレームワークのアプリケーションサーバーはECS Fagateでホストされています。プライベートネットワークに構築しているため、
  ECSからPULLができるようにVPCエンドポイントを設定しています。  ローカル開発環境で本番環境用のDockerfileをビルドし、イメージのECRへのアップロードは手動で行なっています。  

- CloudWatchLogs
  - Fagateで出力されたコンテナのアプリケーションログが出力されています。こちらにもVPCエンドポイントを設定しています。  
- RDS
  - springフレームワークの場合、データベースのマイグレーションはsrc/main/resources/db/migrationにマイグレーション用のsqlを配置すると自動でマイグレーションされます。
  RDSはMySQLで構成されており、FlywayからRDSに向けてマイグレーションが行われます。

- SSMパラメータストア
  - 本番環境の環境変数を管理するのに利用されます。シークレットマネジャーでも良いですが、料金が高いのでこちらで済ませています。

- EC2
  - パブリックネットワークに置かれているEC2インスタンスは単にRDSの中身を調査したり、MySQL Workbenchから接続を行いたい時のために使用されます。  

- CloudFront
  - 一応APIのGetリクエストをキャッシュしているつもりですが、あまり検証できていません。
  
- Route53
  - お名前.comで取得したドメインをRoute53で利用できるようにしています。
  - api用のサブドメインやs３にimageをアップロードするためのサブドメインを利用するためのエイリアスの設定なども行なっています。
  - 証明書を検証するためのレコードも作成しています。

## フロントエンドのネットワーク構築図
バックエンドと比べるとかなりシンプルに構成されています。
![スクリーンショット 2023-04-07 21 39 09](https://user-images.githubusercontent.com/39892315/230610347-b0b5bbd1-fa82-4364-875d-0547b7725b65.png)

### 構成の説明

- App Runner
  - メインとなるNode.jsサーバーです。CSR（クライアントサイドレンダリング）のみならS3で構成しても良いですが、SSRをする場合はNode.jsのサーバーが必要になります。
    ECS Fagateを利用しても良いですが、手軽さでこちらを選びました。
- ECR　
  - App RunnerはDockerイメージをpullして実行されます。元々はDockerを利用せずにgithubリポジトリから直接pullを行い、ビルド、実行をしていましたが、サブモジュールを利用する場合はサブモジュール初期化の設定を行うと実行に失敗したため、Dockerfileでビルドを行うように変更しました。
- CloudWatchLogs
  - アプリケーションのコンテナログを出力しています。
