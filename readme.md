## 这是什么
这是一份开箱即用的zsh配置文件，包含了一些常用的功能和配置，非常适合作为个人zsh配置的基础模板来进行定制。

## 如何食用

1. 移动 `.config/zsh` 到 `~/.config/zsh`中（如果 `~/.config/zsh` 不存在则需要自行创建）
2. 修改 `~/.zshenv`添加以下内容 （如果没有该文件则需要自行创建）
```bash
export ZSH_CONFIG_DIR=~/.config/zsh
```
3. 将`.config`中的文件和文件夹移动到 `~/.config`中
4. 查看`functions.zsh`、`proxy.zsh`等文件内容，并修改为适合你自己的。
   1. 例如修改`proxy.zsh`中的代理地址为你自己的代理地址。
5. 重启终端

## 注意事项
1. 如果你使用`mise`作为包管理器的话（且你已安装），该配置会自动加载`mise`
2. `.config`目录中包含了starship和mise的配置文件，请根据自己实际情况决定是否需要
3. **首次安装过程中会与github进行通信，因此请确保你的网络环境正常**

## 预览

![20251018012232QAs5SldE003534](https://file2.antmoe.com/image/2/2025/10/18/68f27c8b67fef.png)

![20251018013046mthEYMGA003535](https://file2.antmoe.com/image/2/2025/10/18/68f27d5293891.png)

