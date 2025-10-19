export ZDOTDIR="$HOME/.config/zsh"

# 遵循 XDG 基本目录规范，让用户目录更整洁
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# 设置统一的语言和字符集，避免乱码问题
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# 添加用户本地的二进制文件目录到 PATH
export PATH="$HOME/.local/bin:$PATH"
