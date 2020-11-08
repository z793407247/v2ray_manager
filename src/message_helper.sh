MessageType_None='None'
MessageType_Log='Log'
MessageType_Warning='Warning'
MessageType_Error='Error'

load

do_show_message() {
  echo -e $1$2$none
}

show_message() {
  type=$1
  content=$2
  case $type in
  $MessageType_None)
    do_show_message $none$content
    ;;
  $MessageType_Log)
    do_show_message $green$content
    ;;
  $MessageType_Warning)
    do_show_message $yellow$content
    ;;
  $MessageType_Error)
    do_show_message $red$content
    ;;
  esac
}

Log(){
  type=$1
  content=$2
  case $type in
  'i' | 'I')
    show_message $MessageType_None $content
    ;;
  'l' | 'L')
    show_message $MessageType_Log $content
    ;;
  'w' | 'W')
    show_message $MessageType_Warning $content
    ;;
  'e' | 'E')
    show_message $MessageType_Error $content
  ;;
  esac
}

error(){
  show_message $MessageType_Error $1
  exit 1
}
