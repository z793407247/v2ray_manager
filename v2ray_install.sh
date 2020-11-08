#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

# 报错结束
error() {
  echo -e ${red}$1 ${none}
  exit 1
}

# 提示消息
message() {
  case $1 in
  1)
    echo -e ${green}$2 ${none}
    ;;
  2)
    echo -e ${yellow}$2 ${none}
    ;;
  *)
    echo -e $1
    ;;
  esac
  echo
  echo
}

# 玩家主动关闭
say_goodbye() {
  echo -e "欢迎再次使用! finished reason: "${green}$1 ${none}
  exit 0
}

# 检测安装uCRL
check_install_curl() {
  if [ ! $(command -v curl) ]; then
    echo "亲还没有安装cURL呢, 需要帮亲安装嘛?"
    while :; do
      read -p "$(echo -e "是否安装cURL [yes|no]")" _opt
      case $_opt in
      n | N | no | NO)
        say_goodbye "您取消安装cURL呢"
        ;;
      y | Y | YES | yes)
        check_install_dnf
        if [ $? == 0 ]; then
          # 安装好了dnf以后可以安装curl
          dnf makecache
          dnf install curl
          return 0
        else
          error "DNF安装失败了呢!"
        fi
        ;;
      *)
        message 2 "没有理解亲输入的内容呢!"
        ;;
      esac
    done
  else
    return 0
  fi
}

# 检测安装DNF
check_install_dnf() {
  if [ ! $(command -v dnf) ]; then
    echo "亲还没有安装DNF呢, 需要帮亲安装嘛?"
    while :; do
      read -p "$(echo -e "是否安装DNF [yes|no]")" _opt
      case $_opt in
      n | N | no | NO)
        say_goodbye "您取消安装DNF呢"
        return 1
        ;;
      y | Y | YES | yes)
        if [ ! $(command -v yum) ]; then
          echo ${red}"卧槽! 这个机器竟然没有yum, 换一个机器玩吧! "${none}
          return 1
        fi
        yum install epel-release -y
        yum install dnf -y
        return 0
        ;;
      esac
    done
  else
    return 0
  fi
}

check_install_git() {
  if [ ! $(command -v git) ]; then
    message "不会吧, 你连git都没有的么! 我来给你下载一波"
    read -p "$(echo -e "是否下载git [yes|no]")" _opt
    case $_opt in
    n | N | no | NO)
      say_goodbye "您取消下载git呢！"
      return 1
      ;;
    y | Y | YES | yes)
      check_install_dnf
      if [ $? == 0 ]; then
        dnf install git-all
        return 0
      else
        return 1
      fi
      ;;
    esac
  fi
}

# 检测安装项目工程
check_install_v2ray_manager() {
  message 1 "检测是否下载v2ray管理器"
  if [ ! -d v2ray_manager ]; then
    message 1 "没有下载v2ray管理器呢, 是否需要下载呢? 下载需要有github账户呢!"
    while :; do
      read -p "$(echo -e "是否下载v2ray管理器 [yes|no]")" _opt
      case $_opt in
      n | N | no | NO)
        say_goodbye "您取消下载v2ray管理器了呢！"
        ;;
      y | Y | YES | yes)
        check_install_git
        if [ $? == 0 ]; then
          git clone https://github.com/z793407247/v2ray_manager
          return 0
        else
          return 1
        fi
        ;;
      *)
        message 2 "输入错误"
        ;;
      esac
    done
  else
    return 0
  fi
}

delete_v2ray_cmd() {
  local _rc=sed -n "1,1p" ~/.bashrc
  local line=1
  while [[ -n $_rc ]]; do
    _rc=$(sed -n "${line},${line}p" ~/.bashrc)
    local _prefix=[[expr substr "${_rc}" 2 5}]]
    if [ "${_prefix}" == "v2ray" ]; then
      sed "${line}d"
    else
      line=${line+1}
    fi
  done
}

#
#
#
#
#
#
# 开始安装
_sys_language=$LANG
if [ $_sys_language == 'en_US.UTF-8' ]; then
  message 1 "if messages are error (or unintelligible) codes please install chinese language support >> yum install -y kde-l10n-Chinese"
fi

#检测是否有项目工程
# 检测有没有v2ray进程
_v2ray_pid=$(pgrep -f v2ray)

if [[ -n $_v2ray_pid ]]; then
  message 1 "当前有v2ray进程正在运行, 我帮你关掉了!"
  kill -9 $__v2ray_pid
fi

# 尝试删除原来安装的v2ray 可能删除不完全 需要自己处理一下
message 2 "安装v2ray需要删除旧版本, 我这边试着帮你删掉, 删不掉需要自己搞定了!"

if [ -d /usr/bin/v2ray/ ]; then
  message "尝试删除/usr/bin/v2ray/"
  rm -r /usr/bin/v2ray/
fi

if [ -f /etc/systemd/system/v2ray.service ]; then
  message "尝试删除/etc/systemd/system/v2ray.service"
  rm /etc/systemd/system/v2ray.service
fi

if [ -f /lib/systemd/system/v2ray.service ]; then
  message "尝试删除/lib/systemd/system/v2ray.service"
  rm /lib/systemd/system/v2ray.service
fi

if [ -d /etc/init.d/v2ray ]; then
  message "尝试删除/etc/init.d/v2ray"
  rm /etc/init.d/v2ray
fi

# 尝试移动旧配置文件
if [ -f /etc/v2ray ]; then
  message "尝试移动旧配置文件"
  mv -f /etc/v2ray/ /usr/local/etc/
fi

# 开始安装v2ray
check_install_v2ray_manager
if [ $? != 0 ]; then
  error "v2ray管理器下载失败了呢"
fi

# 将管理器复制到合适的地方
if [ -d /usr/local/etc/v2ray/v2ray_manager ]; then
  rm -rf /usr/local/etc/v2ray/v2ray_manager
fi

# 将管理器换个地方
if [ ! -d /usr/local/etc/v2ray ]; then
  mkdir /usr/local/etc/v2ray
fi

if [ -d /usr/local/etc/v2ray/v2ray_manager ]; then
  rm -rf /usr/local/etc/v2ray/v2ray_manager
fi
mv -f v2ray_manager /usr/local/etc/v2ray

# 给管理器设置执行权限
chmod -R +x /usr/local/etc/v2ray/v2ray_manager/

check_install_curl
if [ $? == 0 ]; then
  # 从官方下载install_release.sh
  curl -O https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
  {
    bash install-release.sh
  } &
fi
wait

# 删除v2ray指令
delete_v2ray_cmd

# 重写v2ray指令
if [ -d /usr/local/etc/v2ray/v2ray_manager ]; then
  message 1 "writing to .bashrc"
  echo 'v2ray /usr/local/etc/v2ray/v2ray_manager/src/v2ray_main.sh' >>~/.bashrc
  source /root/.bashrc
fi
