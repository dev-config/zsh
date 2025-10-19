# ==============================================================================
#
#                       ✨ 别名速记手册 (aliases.zsh) ✨
#
#   欢迎来到你的命令快捷方式中心！此文件定义了一系列简短的别名，
#   旨在将冗长或常用的命令缩减为几个简单的按键，极大地提升你的终端操作效率。
#
#   结构按功能领域划分，方便查找和扩展。
#
# ==============================================================================


# ===================================================================
# 核心命令替代 (Modern Replacements)
# ===================================================================
# 使用更强大、更美观的现代化工具替代系统自带的核心命令。

# 📁 使用 lsd 替代 ls，并默认开启图标显示
# ▸ 依赖: lsd, Nerd Font 字体
alias ls='lsd --icon always'       # 基础列表
alias ll='lsd -l --icon always'    # 长列表格式
alias la='lsd -a --icon always'    # 显示所有文件 (包括隐藏文件)
alias lla='lsd -la --icon always'  # 长列表格式 + 显示所有文件
alias lt='lsd --tree --icon always' # 以树状结构显示

# 📜 使用 ripgrep 替代 grep
# ▸ 依赖: ripgrep (rg)
alias grep='rg'


# ===================================================================
# 目录导航与文件操作 (Navigation & File Operations)
# ===================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias c='clear'               # 快速清屏


# ===================================================================
# 📦 前端包管理器 (Package Managers)
# ===================================================================
# 命名约定: 第一个字母代表包管理器 (n -> npm, p -> pnpm, y -> yarn)

# --- pnpm ---
alias pi='pnpm install'
alias pid='pnpm install --save-dev'
alias pr='pnpm run'
alias prd='pnpm run dev'
alias prb='pnpm run build'
alias pt='pnpm test'
alias pa='pnpm add'
alias pad='pnpm add -D'

# --- yarn ---
alias yi='yarn install'
alias yid='yarn install --dev'
alias yr='yarn run'
alias yrd='yarn run dev'
alias yrb='yarn run build'
alias yt='yarn test'
alias ya='yarn add'
alias yad='yarn add -D'

# --- npm ---
alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nt='npm test'


# ===================================================================
# 🌿 Git 工作流 (Git Workflow)
# ===================================================================
# --- 常用 Git 操作 ---
alias gs='git status'           # 查看状态
alias ga='git add'              # 添加文件到暂存区
alias gaa='git add .'           # 添加所有变更到暂存区
alias gc='git commit'           # 提交
alias gcm='git commit -m'       # 带信息提交
alias gca='git commit --amend'  # 追加提交
alias gp='git push'             # 推送
alias gpl='git pull'            # 拉取
alias gco='git checkout'        # 切换分支
alias gb='git branch'           # 分支操作
alias lg='lazygit'              # 🚀 启动 lazygit TUI 界面

# ===================================================================
# 🐳 Docker & 容器化
# ===================================================================
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
# 进入正在运行的容器的 shell (用法: dex <容器名>)
alias dex='docker exec -it'


# ===================================================================
# 🔌 代理与网络 (Proxy & Networking)
# ===================================================================
# --- 代理切换 ---
alias setproxy='proxy_on'
alias unsetproxy='proxy_off'
alias proxy='proxy_status'
