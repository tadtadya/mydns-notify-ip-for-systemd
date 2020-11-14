# mydns-notify-ip-for-systemd
Notify IP address of MyDNS (DDNS service) with Systemd timer

[Japanease](README_ja.md)

## Requirement
- dig - Linux command

### Install dig command
#### CentOS(RedHat)

```bash
# yum install bind-utils
```

#### Ubuntu(Debian)

```bash
# apt install dnsutils
```

#### Installation confirmation

```bash
$ dig -v
DiG 9.11.4-P2-RedHat-9.11.4-9.P2.el7
```

## Overview
- Create an IP notification login shell to MyDNS and create a Systemd service that runs the shell.
- Register the created service in the Systemd timer.
- IP notification login to MyDNS at the cycle set by the timer.

## Source configuration

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

*.timer   : Systemd timer to run the service
*.service : The systemd service that the timer runs
*.sh      : The shell in which the service runs
```

## Timer configuration

```
systemd.timer ┬ mydns.timer
              │   └ mydns.service
              │       └ notify-ip.sh
              │
              └ mydns-short.timer
                  └ mydns-short.service
                      └ notify-ip-change.sh
```

## Processing content
MyDNS keeps DNS information for one week. If there is no IP notification for more than a week, you will be directed to an error site. And if there is no IP notification for more than one month, the DNS information will be destroyed (account is valid).

In addition, the IP address change notification is always recorded in the log, but the notification without IP address change will not be recorded in the log until at least 24 hours have elapsed.

So this time I prepared two timers

### mydns.timer
- Whenever the timer starts, IP notification is performed.
- For continuing MyDNS service

### mydns-short.timer
- When the timer starts, it compares it with the previous IP address and notifies you only when it changes.
- For short cycle to monitor and notify IP change

## Usage
### Shell permissions

```bash
# cd /etc/mydns
# chmod +x notify-ip.sh notify-ip-change.sh
```

### Specify MyDNS login information and domain
#### MyDNS login
- mydns.service

```
[Service]
ExecStart=/etc/mydns/notify-ip.sh user:password
```

| parameters | content |
|:---|:---|
| user | MyDNS Master ID |
| password | MyDNS Password |

#### Domain
- mydns-short.service

```
[Service]
ExecStart=/etc/mydns/notify-ip-change.sh user:password sample.com
```

| parameters | content |
|:---|:---|
| user | MyDNS Master ID |
| password | MyDNS Password |
| `sample.com` | domain |

### Register and start timer

```bash
# systemctl daemon-reload
# systemctl enable mydns.timer
# systemctl start mydns.timer
# systemctl enable mydns-short.timer
# systemctl start mydns-short.timer
```

### Change timer interval
- mydns.timer default

```vim
[Timer]
OnCalendar=*-*-* 6:00:0
```

Schedule to run once a day or more and within one week.

The default is to run at 6:00 AM every day.

[How to specify a calendar](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)

- mydns-short.timer default

```vim
[Timer]
OnUnitActiveSec=1min
```

The cycle is short because it also monitors IP changes. Default is 1 minute.

[How to specify the interval](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Parsing%20Time%20Spans)

### Check timer
#### Registration availability

```bash
# systemctl list-timers
```

#### Startup confirmation

```bash
# systemctl status mydns.timer
# systemctl status mydns-short.timer
```

#### Service execution confirmation

```bash
# systemctl status mydns.service
# systemctl status mydns-short.service
```

### Stop timer

```bash
# systemctl stop mydns.timer
# systemctl disable mydns.timer
# systemctl stop mydns-short.timer
# systemctl disable mydns-short.timer
```

Can be stopped individually.

## Future tasks
- Make a shell to extract the source.
- IPv6 support compared to the previous IP address.

## Links
- [MyDNS.jp](https://www.mydns.jp)
- [MyDNS.jp - Usage](https://www.mydns.jp/?MENU=030)