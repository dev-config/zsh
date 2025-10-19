# ~/.config/zsh/proxy.zsh
# ===================================================================
# 🌐 网络代理切换函数
# ===================================================================

proxy_on() {
  export https_proxy=http://127.0.0.1:6152 http_proxy=http://127.0.0.1:6152 all_proxy=socks5://127.0.0.1:6153
  export no_proxy="localhost,127.0.0.1,::1,.local"
  # 同时设置大写和小写变量以获得最佳兼容性
  export HTTPS_PROXY="$https_proxy" HTTP_PROXY="$http_proxy" ALL_PROXY="$all_proxy" NO_PROXY="$no_proxy"
  echo "✅ 代理已开启"
  proxy_status
}

proxy_off() {
  unset https_proxy http_proxy all_proxy no_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY NO_PROXY
  echo "❌ 代理已关闭"
}

proxy_status() {
  echo "---------------------"
  echo "当前代理状态:"
  echo "https_proxy: ${https_proxy:-<未设置>}"
  echo " http_proxy: ${http_proxy:-<未设置>}"
  echo "  all_proxy: ${all_proxy:-<未设置>}"
  echo "---------------------"
}
