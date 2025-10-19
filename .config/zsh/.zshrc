# ==============================================================================
#
#                         Zsh 配置文件
#
#   此文件为 Zsh Shell 的核心配置文件。
#   其结构设计遵循以下逻辑顺序，以确保性能、稳定性和可维护性：
#   一、基础环境定义
#   二、插件管理器加载与全局配置
#   三、核心交互及视觉插件
#   四、补全系统 (关键顺序)
#   五、核心开发环境
#   六、命令行工具集
#   七、Shell 行为与历史记录
#   八、自定义模块加载与兼容性
#   九、欢迎提示
#
# ==============================================================================


## ☰ 基础环境与路径配置
# 此部分设置 Shell 启动所需的最基础的环境变量，尤其是命令搜索路径。

# 功能：将 path, PATH, fpath, FPATH 四个数组变量标记为“唯一”，自动移除重复的路径。
typeset -U path PATH fpath FPATH

# 功能：定义命令的搜索路径 (PATH) 及其优先级 (从左到右依次降低)。
path=(
  $HOME/.local/bin   # 用户通过 pip 等工具本地安装的二进制文件
  $HOME/bin          # 用户存放个人脚本的目录
  /opt/homebrew/bin  # Homebrew 包管理器路径 (适用于 macOS)
  /usr/local/bin     # 系统级的本地二进制文件
  $ZPFX/bin          # Zinit 自身的二进制文件目录
  $path              # 保留并追加系统原始的 PATH
)


## 🔌 Zinit 插件管理器
# 此部分负责 Zinit 自身的安装、加载以及核心功能扩展。
# ▸ 依赖: Zinit 核心功能依赖 `git` 命令。通过 gh-r 安装二进制文件时，
#         需要 `curl` 以及 `tar` 或 `unzip`。
#         请确保这些基础命令已安装 (例如: `sudo apt install git curl unzip`)。

# 功能：检查 Zinit 是否已安装。如果未安装，则自动从 GitHub 克隆。
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}首次运行，正在安装 Zinit 插件管理器...%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}安装成功！%f%b" || \
        print -P "%F{160} 克隆失败，请检查网络连接和 git 是否已安装。%f%b"
fi

# 功能：加载 Zinit 的主程序脚本，使其命令可用。
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
# 功能：注册 Zinit 的补全函数，以便 Tab 补全 Zinit 命令。
autoload -Uz _zinit
# 功能：将 Zinit 的补全函数关联到 `zinit` 命令。
(( ${+_comps} )) && _comps[zinit]=_zinit

# 功能：轻量化加载 Zinit 的核心功能扩展 (Annex)，为 Zinit 赋予更多超能力。
zinit light zdharma-continuum/zinit-annex-as-monitor  # 提供监控功能
zinit light zdharma-continuum/zinit-annex-bin-gem-node # 提供二进制、gem、npm 包安装能力
zinit light zdharma-continuum/zinit-annex-patch-dl   # 提供下载和打补丁能力
zinit light zdharma-continuum/zinit-annex-rust       # 为 Rust 编写的工具提供更好的支持


## ✨ 核心 Shell 交互体验
# 此部分的插件主要用于增强日常的命令行交互，提升视觉效果和操作便捷性。

# 🚀 Starship: 兼具美观、速度与信息量的跨平台提示符。
# ▸ 依赖: 为了完美显示图标，你需要安装并配置一款 Nerd Font 字体。
# 功能：此 Zinit 命令以“程序”模式从 GitHub Releases 下载 Starship，并使用 `atload` 钩子，
#       确保在 `starship` 命令可用后，才执行其初始化脚本。
# 示例: 开箱即用。若需自定义，请编辑 `~/.config/starship.toml` 文件。
zinit ice as"program" from"gh-r" atload'eval "$(starship init zsh)"'
zinit light starship/starship

# 📜 history-search-multi-word: 允许多关键词历史搜索。
# 功能：加载此插件以解决原生 `Ctrl+R` 只能搜索一个连续字符串的问题。
# 示例: 按 `Ctrl+R` 后输入 `git commit` 即可找到包含这两个词的历史记录。
zinit ice lucid wait'0'
zinit light zdharma-continuum/history-search-multi-word

# --- 视觉与辅助功能 (异步加载，提升启动速度) ---
# 功能：`lucid` 和 `wait'0'` 组合，使 Zinit 在后台异步加载后续插件，从而让 Shell 提示符更快出现。
zinit ice lucid wait'0'
# 🧠 zsh-autosuggestions: 输入命令时，以灰色文字提示历史命令。
# 功能：加载此插件，在你输入命令时，自动在光标后显示最匹配的历史命令建议。
# 示例: 只需正常输入命令，按 `→` (右箭头) 或 `End` 键即可采纳建议。
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait'0'
# 🎨 fast-syntax-highlighting: 为你输入的命令提供实时语法高亮。
# 功能：加载此插件，使命令、参数、字符串等显示不同颜色，有效防止语法错误。
# 示例: 输入 `echo "Hello"`，`echo` 和 `"Hello"` 会有不同颜色。
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice lucid wait'0'
# 👉 zsh-you-should-use: 当你使用了某个命令的别名时，友情提醒你。
# 功能：加载此插件，帮助你记忆和巩固自己设置的别名，养成高效习惯。
# 示例: 如果你设置了 `alias g=git`，当你输入 `git` 时，它会提示 `zsh: you should use 'g'`。
zinit light MichaelAquilina/zsh-you-should-use


## 🎯 补全系统
# 此板块遵循“先初始化、再增强”的黄金法则，以确保补全系统稳定运行。

# 功能：初始化 Zsh 的核心补全系统 (`compinit`)。
#       此步骤至关重要，必须在任何试图修改或增强补全功能的插件 (如 fzf-tab) 之前执行。

# ▸ 功能: 初始化 Zsh 的核心补全系统 (`compinit`)。
#         此处的 if/else 逻辑是一个标准的性能优化：它会检查补全缓存文件 (`.zcompdump`) 
#         是否比系统中的任何补全脚本都要新。只有在您安装了新工具 (从而添加了新的补全脚本) 
#         之后，它才会完整地重新生成缓存。在其他情况下，它会直接、快速地加载现有缓存。
autoload -Uz compinit
if [[ -n "$ZDOTDIR/.zcompdump"(#qN.mh+24) ]]; then
  compinit -i -C
else
  compinit -i
fi

# 🗂️ zsh-completions: 社区维护的 Zsh 补全脚本集合。
# 功能：加载此插件，为大量常用工具 (如 docker, systemctl 等) 提供了比系统默认更强大的补全支持。
# 示例: 输入 `docker <TAB>`，会补全出所有子命令和容器名称。
zinit light zsh-users/zsh-completions

# 🔎 fzf: `fzf-tab` 的核心依赖，一个通用的命令行模糊搜索工具。
# 功能：此 Zinit 命令以“程序”模式从 GitHub Releases 下载 fzf，并使用 `mv` 和 `pick`
#       指令处理其打包结构，确保 `fzf` 命令可用。
# 示例: `git branch | fzf | xargs git checkout`（模糊搜索并切换分支）。
zinit ice as"program" from"gh-r" mv="fzf* -> fzf" pick="fzf"
zinit light junegunn/fzf

# ⌨️ fzf-tab: 使用 fzf 接管并增强原生的 Tab 补全界面。
# 功能：加载此插件，提供交互式模糊搜索能力，替代 Zsh 默认的列表式补全。
# 示例: 输入 `git checkout <TAB>`，会列出所有分支供你搜索选择。
zinit light Aloxaf/fzf-tab

# 🗃️ extract: Oh My Zsh 的通用解压插件。
# 功能：加载此插件片段，提供一个 `extract` 命令，能自动识别并解压各种类型的压缩文件。
# 示例: `extract archive.tar.gz`
zinit ice lucid wait'0'
zinit snippet OMZP::extract

# --- 配置补全行为与视觉效果 ---
# 此部分使用 Zsh 的 zstyle 命令，为 fzf-tab 插件和 Zsh 的原生补全系统
# 配置详细的预览行为和显示样式，以极大地提升交互体验。

# ▸ 描述: 通用文件内容预览器。
# 功能：此为 fzf-tab 的“通配符”规则，当补全任何命令的参数且该参数为文件时，
#       自动使用 bat 命令在预览窗口中显示该文件的内容（最多显示前50行）。
# 示例: 输入 `vim <TAB>` 并高亮 `index.js`，预览窗口会显示 `index.js` 的源代码。
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --plain --line-range :50 $realpath'

# ▸ 描述: 前端项目脚本预览器。
# ▸ 依赖: 需要 jq 命令 (已在“CLI 工具军火库”中通过 Zinit 自动安装)。
# 功能：当补全 npm, yarn, 或 pnpm 的脚本时，使用 jq 解析 package.json，
#       并在预览窗口中显示该脚本实际执行的命令内容。
# 示例: 输入 `pnpm run <TAB>` 并高亮 `dev`，预览窗口会显示 `"vite --host"`。
zstyle ':fzf-tab:complete:npm:run:*' fzf-preview 'jq ".scripts[\"$word\"]" package.json'
zstyle ':fzf-tab:complete:yarn::*' fzf-preview 'jq ".scripts[\"$word\"]" package.json'
zstyle ':fzf-tab:complete:pnpm::*' fzf-preview 'jq ".scripts[\"$word\"]" package.json'

# 功能：此 if/else 结构为不同操作系统 (macOS 与 Linux) 提供专属的、
#       更美观或更兼容的命令预览，因为 `ps` 等命令在不同系统下参数有差异。
if [[ "$OSTYPE" == "darwin"* ]]; then
    # ▸ 描述: 目录内容预览 (macOS)。
    # 功能：当使用 `cd` 或 `z` 命令补全目录时，使用 `lsd` 在预览窗口中显示该目录的内容。
    # 示例: 输入 `cd <TAB>` 或 `z <TAB>` 并高亮 `~/Documents`，预览窗口会列出 `Documents` 目录下的文件。
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always --icon=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'lsd -1 --color=always --icon=always $realpath'
    # ▸ 描述: Git 分支提交记录预览 (macOS)。
    # 功能：当使用 `git checkout` 补全分支时，使用 `git log` 在预览窗口中显示该分支的提交历史图。
    # 示例: 输入 `git checkout <TAB>` 并高亮 `feature/new-login`，预览窗口会显示其提交记录。
    zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --oneline --graph --color=always $word | head -20'
    # ▸ 描述: 进程信息预览 (macOS)。
    # 功能：当使用 `kill` 命令补全进程时，使用 `ps` 在预览窗口中显示该进程的详细信息。
    # 示例: 输入 `kill <TAB>` 并高亮一个 `node` 进程，预览窗口会显示其 PID、CPU 和内存占用。
    zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps -p $realpath[#,-1] -o pid,%cpu,%mem,comm -c' --height=20
else
    # ▸ 描述: 目录内容预览 (Linux)。
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always --icon=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'lsd -1 --color=always --icon=always $realpath'
    # ▸ 描述: Git 分支提交记录预览 (Linux)。
    zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --oneline --graph --color=always $word | head -20'
    # ▸ 描述: 进程信息预览 (Linux)。
    zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps --pid=$realpath[#,-1] -o pid,%cpu,%mem,cmd --width=${COLUMNS} --color=always' --height=20
fi

# ▸ 描述: Zsh 原生补全菜单样式。
# 功能：配置 Zsh 的原生补全菜单（当 fzf-tab 未激活时）以列表形式展示，
#       允许使用方向键进行选择，而不是将所有选项平铺在屏幕上。
zstyle ':completion:*' menu select


## 🛠️ 核心开发环境
# 🚀 mise: 面向未来的多语言版本管理器。
# ▸ 依赖: 此工具需要你通过官方方式 (如 curl 脚本或 Homebrew) 预先安装好。
# 功能：检查 `mise` 命令是否存在，如果存在，则执行其初始化脚本以接管 Shell 环境。
# 示例: 在项目 A 中 `mise use node@20`，在项目 B 中 `mise use node@18`，当你 `cd` 目录时会自动切换。
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi


## 🧰 CLI 工具军火库
# 此区域通过 Zinit 安装了一系列强大的现代化命令行工具，以提升终端工作效率。

# 🧠 Atuin: 拥有“魔法记忆”的 Shell 历史记录工具。
# 功能：此 Zinit 命令使用复杂的专家级安装模式，在安装时自动生成初始化和补全脚本，以获得极致的加载性能。
# 示例: 按 `Ctrl+R` 启动 TUI 界面，输入 `npm run` 即可搜索所有执行过的 `npm run` 命令。
zinit ice as"command" from"gh-r" bpick"atuin-*.tar.gz" mv="atuin*/atuin -> atuin" \
    atclone"./atuin init zsh > init.zsh; ./atuin gen-completions --shell zsh > _atuin" \
    atpull"%atclone" src="init.zsh"
zinit light atuinsh/atuin

# ⚡️ Zoxide: AI 赋能的 `cd` 命令。
# 功能：此 Zinit 命令使用 `atload` 钩子，确保在 `zoxide` 命令可用后，才执行其初始化脚本。
# 示例: 输入 `z proj` 即可直接跳转到你最常访问的、包含 `proj` 的目录。
zinit ice as"program" from"gh-r" atload'eval "$(zoxide init zsh)"; unalias zi'
zinit light ajeetdsouza/zoxide

# 📜 jq: 命令行的 JSON 数据处理器，前端必备。
# 功能：此 Zinit 命令使用 `mv` 指令来处理 `jq-macos-arm64` 这种带平台信息的命名方式。
# 示例: `cat package.json | jq '.scripts'` (仅显示 package.json 中的 scripts 对象)。
zinit ice as"program" from"gh-r" mv"jq-* -> jq"
zinit light jqlang/jq

# 📁 lsd: `ls` 命令的现代替代品。
# ▸ 依赖: 为了完美显示图标，你需要安装并配置一款 Nerd Font 字体。
# 功能：此 Zinit 命令使用 `mv="*/lsd -> lsd"` 指令，精确处理其二进制文件被打包在子目录中的情况。
# 示例: `lsd -l --icon always` (带图标的长列表), `lsd --tree` (树状视图)。
zinit ice as"program" from"gh-r" mv="*/lsd -> lsd"
zinit light lsd-rs/lsd

# 📖 bat: 带翅膀的 `cat` 命令。
# 功能：此 Zinit 命令使用 `mv` 和 `pick` 指令，处理其二进制文件被打包在带版本号的子目录中的情况。
# 示例: `bat index.js` (自动高亮), `bat -l rs` (指定语言为 Rust)。
zinit ice as"command" from"gh-r" mv="bat*/bat -> bat" pick="bat"
zinit light sharkdp/bat

# 🎯 fd: `find` 命令的人性化替代品。
# 功能：此 Zinit 命令使用 `mv` 和 `pick` 指令，处理其二进制文件被打包在带版本号的子目录中的情况。
# 示例: `fd 'package.json'` (查找所有 `package.json` 文件), `fd -e md` (查找所有 Markdown 文件)。
zinit ice as"command" from"gh-r" mv="fd*/fd -> fd" pick="fd"
zinit light sharkdp/fd

# 📜 ripgrep (rg): `grep` 命令的超高速替代品。
# 功能：此 Zinit 命令使用复杂的 `mv` 和 `pick` 指令，处理其二进制文件名为 `rg` 且被打包在多层子目录中的特殊情况。
# 示例: `rg 'useState'` (在当前目录搜索 `useState`), `rg -t ts 'React'` (仅在 TS 文件中搜索 `React`)。
zinit ice from"gh-r" as"program" mv="ripgrep* -> ripgrep" pick="ripgrep/rg"
zinit light BurntSushi/ripgrep

# ✍️ sd: 更直观的流式查找与替换工具。
# 功能：此 Zinit 命令使用 `mv="*/sd -> sd"` 指令，精确处理其二进制文件被打包在子目录中的情况。
# 示例: `rg old-api | sd 'old-api' 'new-api' > new_file.txt`。
zinit ice as"program" from"gh-r" mv="*/sd -> sd"
zinit light chmln/sd

# 🚀 lazygit: Git 的终极终端神器。
# 功能：此 Zinit 命令使用 `as"program"` 的智能模式进行安装，适用于打包规范的工具。
# 示例: 在任何 Git 仓库中运行 `lg` (需在别名文件中设置 `alias lg='lazygit'`) 即可启动。
zinit ice as"program" from"gh-r"
zinit light jesseduffield/lazygit

# 📊 delta: `git diff` 的高级伴侣。
# 功能：此 Zinit 命令使用 `mv` 和 `pick` 指令，处理其二进制文件被打包在带版本号的子目录中的情况。
# 示例: 在 `.gitconfig` 中配置后，`git diff`, `git show` 等命令会自动生效。
zinit ice as"command" from"gh-r" mv="delta* -> delta" pick="delta/delta"
zinit light dandavison/delta

# ⏱️ hyperfine: 命令行程序的性能评测专家。
# 功能：此 `if/else` 结构和 `bpick` 指令用于为不同操作系统精确选择要下载的压缩包，
#       并通过 `mv` 和 `pick` 处理其复杂的打包结构。
# 示例: `hyperfine 'fd .md' 'find . -name "*.md"'` (对比 `fd` 和 `find` 的性能)。
if [[ "$OSTYPE" == darwin* ]]; then
    zinit ice as"program" from"gh-r" bpick"*apple-darwin*.tar.gz" mv"hyperfine-*/hyperfine -> hyperfine" pick="hyperfine"
else
    zinit ice as"program" from"gh-r" bpick"*unknown-linux-gnu*.tar.gz" mv"hyperfine-*/hyperfine -> hyperfine" pick="hyperfine"
fi
zinit light sharkdp/hyperfine

# 🌐 doggo: 现代化的 DNS 查询工具。
# 功能：此 Zinit 命令使用 `atpull'chmod +x doggo'` 钩子，在安装后强制赋予文件可执行权限。
# 示例: `digg google.com` (需在别名文件中设置 `alias digg='doggo'`)。
zinit ice as"program" from"gh-r" mv="*/doggo -> doggo"
zinit light mr-karan/doggo

# 📝 pet: 简单的命令行代码片段管理器。
# 功能：此 Zinit 命令使用 `mv` 指令处理其二进制文件被打包在子目录中的情况。
# 示例: `pet new` (新增片段), `pet search` (搜索片段)。
zinit ice as"program" from"gh-r" mv="pet* -> pet"
zinit light knqyf263/pet

# 📈 httpstat: 可视化的 `curl` 统计报告。
# 功能：此 Zinit 命令使用 `atpull'!git reset --hard'` 钩子，在更新时丢弃本地修改，保持插件纯净。
# 示例: `httpstat https://google.com`。
zinit ice as"program" mv="httpstat.sh -> httpstat" pick="httpstat" atpull'!git reset --hard'
zinit light b4b4r07/httpstat


## ⚙️ Shell 基础行为与历史记录设定
# 功能：配置 Zsh 的核心交互行为，例如自动 `cd`、历史记录共享等。
setopt autocd extended_glob interactive_comments no_beep hist_ignore_all_dups hist_ignore_space
setopt hist_verify inc_append_history share_history auto_menu

# 功能：配置历史记录文件路径和大小。
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=100000; export SAVEHIST=100000


## 🚀 加载自定义配置模块与兼容性配置
# 功能：定义一个包含所有自定义配置模块路径的数组。
local config_files=("$ZDOTDIR/aliases.zsh" "$ZDOTDIR/functions.zsh" "$ZDOTDIR/proxy.zsh")
# 功能：遍历数组，并安全地加载每一个存在的配置文件。
for file in "$config_files[@]"; do
  [[ -r "$file" ]] && source "$file"
done
unset file config_files # 清理临时变量，保持环境干净。

# 功能：加载 `.profile` 文件，以兼容只识别该文件的老旧程序。
[ -f ~/.profile ] && source ~/.profile


## 👋 欢迎提示
# 功能：仅在交互式 Shell (你日常使用的终端) 中执行 `greet_user` 函数，显示欢迎信息。
[[ $- == *i* ]] && greet_user

