# mydns-notify-ip-for-systemd
DDNSサービスのMyDNSのIP通知をLinux systemdのタイマーでコントロールします。

[English](README.md)

## 要件
- dig - Linux command

### digコマンドのインストール
#### CentOS(RedHat)

```bash
# yum install bind-utils
```

#### Ubuntu(Debian)

```bash
# apt install dnsutils
```

#### インストール確認

```bash
$ dig -v
DiG 9.11.4-P2-RedHat-9.11.4-9.P2.el7
```

## Overview
- MyDNSへのIP通知ログインシェルを作成してシェルを実行するSystemdのサービスを作成します。
- 作成したサービスをSystemdのタイマーに登録します。
- タイマーで設定したサイクルでMyDNSへIP通知ログインを行います。

## ソース構成

```
/etc
  ├ mydns
  │   ├ notify-ip.sh
  │   └ notify-ip-change.sh
  │
  └ systemd
      └ system
          ├ mydns.service
          ├ mydns.timer
          ├ mydns-short.service
          └ mydns-short.timer

*.timer   : サービスを実行するsystemdタイマー
*.service : タイマーが実行するsystemdサービス
*.sh      : サービスが実行するシェル
```

## タイマー構成

```
systemd.timer ┬ mydns.timer
              │   └ mydns.service
              │       └ notify-ip.sh
              │
              └ mydns-short.timer
                  └ mydns-short.service
                      └ notify-ip-change.sh
```

## 処理内容
MyDNSでのDNS情報の保持期間は1週間です。1週間以上IP通知がないとエラーサイトに誘導されます。そして、1ヶ月以上IP通知がないとDNS情報が破棄されます（アカウントは有効）。

また、IPアドレス変更の通知のときはつねにログに記録されますが、IPアドレスに変更のない通知は24時間以上経過しないとログに記録されません。

そこで今回は2つのタイマーを用意しました。

### mydns.timer
- タイマーが起動すると必ずIP通知を行う。
- MyDNSのサービス継続用

### mydns-short.timer
- タイマーが起動すると前回のIPアドレスと比較し、変わっているときだけIP通知を行う。
- IP変更を監視して通知するショートサイクル用。

## Usage
### シェルの権限

```bash
# cd /etc/mydns
# chmod +x notify-ip.sh notify-ip-change.sh
```

### MyDNSのログイン情報・ドメイン指定
#### MyDNSログイン
- mydns.service

```
[Service]
ExecStart=/etc/mydns/notify-ip.sh user:password sample.com
```

| パラメータ | 内容 |
|:---|:---|
| user | MyDNSのマスターID |
| password | MyDNSのパスワード |
| `sample.com` | ドメイン |

#### ドメイン
- mydns-short.service

```
[Service]
ExecStart=/etc/mydns/notify-ip-change.sh sample.com
```

| パラメータ | 内容 |
|:---|:---|
| `sample.com` | ドメイン |

### タイマーの登録と起動

```bash
# systemctl daemon-reload
# systemctl enable mydns.timer
# systemctl start mydns.timer
# systemctl enable mydns-short.timer
# systemctl start mydns-short.timer
```

### タイマーのインターバル変更
- mydns.timer default

```vim
[Timer]
OnCalendar=*-*-* 6:00:0
```

1日以上1週間以内に1回実行するようにスケジューリングします。

デフォルトは毎日AM6:00に実行します。

[カレンダーの指定方法](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)

- mydns-short.timer default

```vim
[Timer]
OnUnitActiveSec=1min
```

IP変更の監視もするのでサイクルは短いです。デフォルトは1分です。

[インターバルの指定方法](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Parsing%20Time%20Spans)

### タイマーの確認
#### 登録可否

```bash
# systemctl list-timers
```

#### 起動確認

```bash
# systemctl status mydns.timer
# systemctl status mydns-short.timer
```

#### サービスの実行確認

```bash
# systemctl status mydns.service
# systemctl status mydns-short.service
```

### タイマーの停止

```bash
# systemctl stop mydns.timer
# systemctl disable mydns.timer
# systemctl stop mydns-short.timer
# systemctl disable mydns-short.timer
```

それぞれに停止も可能。

## 今後の課題
- ソースを展開するシェルを作る。
- 前回のIPアドレスとの比較のIPv6対応。

## リンク
- [MyDNS.jp](https://www.mydns.jp)
- [MyDNS.jp - Usage](https://www.mydns.jp/?MENU=030)
