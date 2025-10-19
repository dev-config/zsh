# ==============================================================================
#
#                      🛠️ 自定义 Zsh 函数库 (functions.zsh) 🛠️
#
#   欢迎来到你的 Shell "超能力"中心！此文件存放了比别名更强大的自定义函数，
#   它们可以包含逻辑判断、接收参数，并能完成更复杂的自动化任务。
#
# ==============================================================================


# ===================================================================
# 👋 基础与欢迎函数
# ===================================================================

greet_user() {
  echo "欢迎回来, $USER"
  echo "现在时间: $(date +"%Y-%m-%d %H:%M:%S")"
}


# ===================================================================
# 🚀 开发与工作流 (Development & Workflow)
# ===================================================================

# --- 创建并进入目录 ---
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# --- ✨ Zoxide Tab 补全修复函数 ---
# ▸ 功能: 重写z命令，使z可以补全历史记录。
#         它手动调用 `zoxide query -l` 获取历史目录，并结合当前目录下的文件夹，
#         最终通过 `compadd` 将一个完美的补全列表提供给 Zsh 和 fzf-tab。
#         这从根源上解决了 `z <TAB>` 无法补全历史记录的问题。
_zoxide_z() {
  local -a matches
  matches=($(zoxide query -l 2>/dev/null))
  matches+=($(find . -maxdepth 1 -type d -not -path '.' 2>/dev/null))
  compadd -a matches
}
compdef _zoxide_z z

# --- 🛰️ 一站式网络 IP 查询 (简洁重构版) ---
# ▸ 功能: 智能获取物理网卡IP，顺序查询多个公网IP服务，输出简洁易读
# ▸ 依赖: curl
# ▸ 示例: myip
myip() {
  local GREEN='\e[0;32m'
  local BLUE='\e[0;34m'
  local YELLOW='\e[0;33m'
  local RED='\e[0;31m'
  local GRAY='\e[0;90m'
  local NC='\e[0m'

  echo "${BLUE}🔍 正在查询网络信息...${NC}"
  echo

  # 获取本地IP - 优先物理网卡，排除虚拟接口
  _get_local_ip

  echo
  echo "${BLUE}🌐 公网IP查询结果:${NC}"

  # 定义服务配置 - 统一格式：URL|显示名称|类型|解析函数
  local services=(
    # 国内服务
    "http://myip.ipip.net|IPIP.NET|domestic|_parse_ipip"
    "https://2025.ip138.com|IP138.COM|domestic|_parse_ip138"
    "https://api-v3.speedtest.cn/ip|SpeedTest.CN|domestic|_parse_speedtest"
    # 国外服务  
    "https://api.myip.la/cn?json|MyIP.LA|international|_parse_myip_json"
    "https://ifconfig.me/all.json|IfConfig|international|_parse_ifconfig_json"
    "https://api.ipify.org?format=json|Ipify|international|_parse_ipify_json"
    "https://api-ipv4.ip.sb/ip|IP.SB|international|_parse_simple"
    "ipinfo.io|IPInfo.IO|international|_parse_ipinfo"
  )

  local domestic_success=0 domestic_total=0
  local international_success=0 international_total=0
  local current_type=""

  # 顺序查询所有服务
  for service in "${services[@]}"; do
    local url="${service%%|*}"
    local remaining="${service#*|}"
    local name="${remaining%%|*}"
    remaining="${remaining#*|}"
    local type="${remaining%%|*}"
    local parser="${remaining##*|}"

    # 显示分类标题
    if [[ "$type" != "$current_type" ]]; then
      current_type="$type"
      if [[ "$type" == "domestic" ]]; then
        echo "${BLUE}📍 国内服务查询结果:${NC}"
      else
        echo "${BLUE}🌍 国外服务查询结果:${NC}"
      fi
    fi

    # 统计总数
    if [[ "$type" == "domestic" ]]; then
      ((domestic_total++))
    else
      ((international_total++))
    fi

    # 查询服务
    local result=$(_query_service "$url" "$parser")
    
    # 直接输出结果，不使用动态更新
    if [[ "$result" != "FAILED" ]]; then
      echo "   ${GREEN}✓${NC} $name: $result"
      if [[ "$type" == "domestic" ]]; then
        ((domestic_success++))
      else
        ((international_success++))
      fi
    else
      echo "   ${RED}✗${NC} $name: 查询失败"
    fi
  done

  # 显示统计信息
  echo
  echo "${BLUE}📊 查询统计:${NC}"
  echo "   国内服务: ${domestic_success}/${domestic_total} 成功"
  echo "   国外服务: ${international_success}/${international_total} 成功"
}

# 获取本地IP的辅助函数
_get_local_ip() {
  local local_ip="" interface="" interface_type=""

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: 检查物理网络接口状态和IP
    for iface in en0 en1 en2 en3; do
      if networksetup -getinfo "Wi-Fi" 2>/dev/null | grep -q "IP address: " && [[ "$iface" == "en0" ]]; then
        local_ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
        [[ -n "$local_ip" ]] && { interface="$iface"; interface_type="Wi-Fi"; break; }
      elif networksetup -listallhardwareports 2>/dev/null | grep -A1 "Ethernet" | grep -q "$iface"; then
        local_ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
        [[ -n "$local_ip" ]] && { interface="$iface"; interface_type="以太网"; break; }
      fi
    done
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux: 严格排除虚拟接口，优先物理网卡
    for iface in $(ip -o link show up | awk -F': ' '{print $2}' | grep -E '^(eth|enp|ens|wlan|wlp)' | grep -vE '(docker|veth|lo|tun|tap|br-|virbr|vbox)'); do
      local_ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{print $2}' | cut -d'/' -f1 | head -1)
      if [[ -n "$local_ip" ]]; then
        interface="$iface"
        [[ "$iface" =~ ^(wlan|wlp) ]] && interface_type="Wi-Fi" || interface_type="以太网"
        break
      fi
    done
  fi

  # 显示本地IP
  if [[ -n "$local_ip" ]]; then
    echo "📍 ${GREEN}本地IP${NC}: $local_ip ${GRAY}($interface_type - $interface)${NC}"
  else
    echo "📍 ${RED}本地IP${NC}: 未找到活跃的物理网络接口"
  fi
}

# 统一的服务查询函数
_query_service() {
  local url="$1"
  local parser="$2"
  local response
  
  # 设置完整的浏览器请求头
  local user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
  
  # 特殊处理ipinfo.io服务，随机选择token
  if [[ "$url" == "ipinfo.io" ]]; then
    local tokens=("b44d264500f926" "5886e32e75537e" "230de83c74e3f3" "41c48b54f6d78f" "ba0234c01f79d3" "21a2f355f4c4b9" "d811bd45b5fcf5" "c31843916e5fd7")
    local random_token=${tokens[$((RANDOM % ${#tokens[@]}))]}
    url="https://ipinfo.io/json?token=$random_token"
  fi
  
  # 为IP138添加额外的请求头，并使用-L参数跟随重定向，不使用gzip压缩
  if [[ "$url" == *"ip138.com"* ]]; then
    response=$(curl -sL --connect-timeout 3 --max-time 5 \
      -H "User-Agent: $user_agent" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
      -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8" \
      -H "Connection: keep-alive" \
      -H "Upgrade-Insecure-Requests: 1" \
      "$url" 2>/dev/null)
  else
    response=$(curl -sL --connect-timeout 3 --max-time 5 -H "User-Agent: $user_agent" "$url" 2>/dev/null)
  fi
  
  if [[ -n "$response" ]]; then
    # 检查解析器是否需要从stdin读取（如_parse_ip138）
    if [[ "$parser" == "_parse_ip138" ]]; then
      echo "$response" | $parser
    else
      # 对于简单解析器，去除响应中的换行符和空白字符
      if [[ "$parser" == "_parse_simple" ]]; then
        response=$(echo "$response" | tr -d '\n\r' | xargs)
      fi
      $parser "$response"
    fi
  else
    echo "FAILED"
  fi
}

# 各种解析函数
_parse_ipip() {
  local response="$1"
  local ip=$(echo "$response" | sed -n 's/.*当前 IP：\([0-9.]*\).*/\1/p')
  local location=$(echo "$response" | sed -n 's/.*来自于：\(.*\)/\1/p')
  
  if [[ -n "$ip" && -n "$location" ]]; then
    echo "$ip ${GRAY}($location)${NC}"
  elif [[ -n "$ip" ]]; then
    echo "$ip"
  else
    echo "FAILED"
  fi
}

_parse_ip138() {
  local response=$(cat)  # 从stdin读取
  
  # 调试信息：检查响应内容
  if [[ -n "$DEBUG_IP138" ]]; then
    echo "DEBUG: IP138响应长度: ${#response}" >&2
    echo "DEBUG: IP138响应前200字符: ${response:0:200}" >&2
    echo "DEBUG: 是否包含IP链接: $(echo "$response" | grep -c 'target="_blank"')" >&2
    echo "DEBUG: 是否包含来自信息: $(echo "$response" | grep -c '来自：')" >&2
  fi
  
  # 从body内容提取IP地址
  local ip=$(echo "$response" | grep -o 'target="_blank">[0-9.]*</a>' | sed 's/target="_blank">//' | sed 's/<\/a>//' | head -1 | tr -d '\n\r')
  # 提取地理位置信息
  local location=$(echo "$response" | grep -o '来自：[^<]*' | sed 's/来自：//' | tr -d '\n\r')
  
  # 调试信息：显示提取结果
  if [[ -n "$DEBUG_IP138" ]]; then
    echo "DEBUG: 提取的IP: '$ip'" >&2
    echo "DEBUG: 提取的位置: '$location'" >&2
  fi
  
  if [[ -n "$ip" && -n "$location" ]]; then
    echo "$ip ${GRAY}($location)${NC}"
  elif [[ -n "$ip" ]]; then
    echo "$ip"
  else
    # 如果解析失败，提供更多信息
    if [[ -z "$response" ]]; then
      echo "FAILED (无响应数据)"
    elif [[ ${#response} -lt 50 ]]; then
      echo "FAILED (响应过短: ${#response}字符)"
    else
      echo "FAILED (解析失败)"
    fi
  fi
}

_parse_speedtest() {
  local response="$1"
  local code=$(echo "$response" | sed -n 's/.*"code":\s*\([0-9]*\).*/\1/p')
  
  if [[ "$code" == "0" ]]; then
    local ip=$(echo "$response" | sed -n 's/.*"ip":\s*"\([^"]*\)".*/\1/p')
    local country=$(echo "$response" | sed -n 's/.*"country":\s*"\([^"]*\)".*/\1/p')
    local province=$(echo "$response" | sed -n 's/.*"province":\s*"\([^"]*\)".*/\1/p')
    local isp=$(echo "$response" | sed -n 's/.*"isp":\s*"\([^"]*\)".*/\1/p')
    
    if [[ -n "$ip" ]]; then
      local location="$country $province $isp"
      echo "$ip ${GRAY}($location)${NC}"
    else
      echo "FAILED"
    fi
  else
    echo "FAILED"
  fi
}

_parse_simple() {
  local response="$1"
  if [[ "$response" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$response"
  else
    echo "FAILED"
  fi
}

_parse_myip_json() {
  local response="$1"
  
  # 提取IP地址和地理位置信息
  local ip=$(echo "$response" | grep -o '"ip"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  local country=$(echo "$response" | grep -o '"country_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  local province=$(echo "$response" | grep -o '"province"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  
  if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # 构建地理位置信息
    local location=""
    if [[ -n "$country" && "$country" != "null" ]]; then
      location="$country"
    fi
    if [[ -n "$province" && "$province" != "null" && "$province" != "$country" ]]; then
      if [[ -n "$location" ]]; then
        location="$location, $province"
      else
        location="$province"
      fi
    fi
    
    if [[ -n "$location" ]]; then
      echo "$ip ($location)"
    else
      echo "$ip"
    fi
  else
    echo "FAILED"
  fi
}

_parse_ipinfo() {
  local response="$1"
  
  # 使用grep和sed提取JSON字段
  local ip=$(echo "$response" | grep -o '"ip"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  local city=$(echo "$response" | grep -o '"city"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  local region=$(echo "$response" | grep -o '"region"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  local country=$(echo "$response" | grep -o '"country"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  
  if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # 构建地理位置信息
    local location=""
    if [[ -n "$city" && "$city" != "null" ]]; then
      location="$city"
    fi
    if [[ -n "$region" && "$region" != "null" && "$region" != "$city" ]]; then
      if [[ -n "$location" ]]; then
        location="$location, $region"
      else
        location="$region"
      fi
    fi
    if [[ -n "$country" && "$country" != "null" ]]; then
      if [[ -n "$location" ]]; then
        location="$location, $country"
      else
        location="$country"
      fi
    fi
    
    if [[ -n "$location" ]]; then
      echo "$ip ($location)"
    else
      echo "$ip"
    fi
  else
    echo "FAILED"
  fi
}

_parse_ifconfig_json() {
  local response="$1"
  
  # 提取IP地址
  local ip=$(echo "$response" | grep -o '"ip_addr"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  
  if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$ip"
  else
    echo "FAILED"
  fi
}

_parse_ipify_json() {
  local response="$1"
  
  # 提取IP地址
  local ip=$(echo "$response" | grep -o '"ip"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
  
  if [[ -n "$ip" && "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$ip"
  else
    echo "FAILED"
  fi
}


