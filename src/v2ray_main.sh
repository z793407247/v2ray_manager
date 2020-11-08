base_dir='/usr/local/etc/v2ray/v2ray_manager/src' # 资源目录

# 加载脚本
load_script() {
  local script_name=$1
  local _param=$2
  if [[ -z $script_name ]]; then
    Log 'e' '加载脚本时没有传递正确的脚本名!'
    return 1
  else
    # shellcheck source=${base_dir}${script_name}.sh
    . ${base_dir}${script_name}.sh $_param
  fi

  return 0
}

# 加载工具脚本
load_script utils          # 工具类
load_script color          # 颜色类
load_script message_helper # 消息提示

# 获取参数
_args=$1
_param=$2

case $_args in
'menu' | 'Menu' | 'MENU')
  load_script menu $_param
  ;;
'info' | 'Info' | 'INFO' | 'i' | 'I')
  load_script info
;;
esac
