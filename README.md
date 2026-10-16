# 黑柩 小游戏

《黑柩》同人网页小游戏四件。**单文件、零外部依赖、手机与桌面都能玩。**

```
站点    https://darkcoffin-game.hubingsf.cn
仓库    https://github.com/darkcoffin-game/darkcoffin-game.github.io
```

---

## 进站之前（请先读）

1. 本站作品**全部由 AI 创作**，不保证严谨与准确。发现错漏，请以《黑柩》设定集与
   [黑柩创作站](https://darkcoffin.hubingsf.cn) 为准。
2. 内容是基于《黑柩》设定集的**再演绎**，与设定集及其他黑柩内容**可能不相容**。
3. 作品取材于设定集的某些时期，并对其未写明处作了**推定与补写**；介意剧透者请先读设定集。
4. 内容含**行政暴力、政治迫害、处刑与死亡**的描写，请自行判断是否适合游玩。
5. 四件作品均**不保存进度**，刷新或关闭即从头开始。
6. 《黑柩》相关内容**版权归原作者所有**；全部人物、组织、事件均属虚构，与现实中任何个人、
   团体、事件无关。

---

## 四件作品

| # | 作品 | 一句话 | 特色 | 体量 |
|---:|---|---|---|---|
| 01 | [戡乱政府 · 用印五日](https://darkcoffin-game.hubingsf.cn/yongyin.html) | 你是戡乱政府第四办事口掌印的人。五天，三十份材料，一枚章。 | 短小精悍，小有回味 | 22 KB ｜ 3–5 分钟 ｜ 6 个结局 |
| 02 | [命途转盘 · 北沙 · 白色恐怖](https://darkcoffin-game.hubingsf.cn/beisha.html) | 你是北沙宪兵队里的一名宪兵，从入城那天到清场之后，一整年。 | 体验较长，故事严肃 | 549 KB ｜ 约 40–60 分钟 ｜ 148 件事件 · 45 个结局 ｜ 两个身份可玩 |
| 03 | [和平会议 · 七日](https://darkcoffin-game.hubingsf.cn/qiri.html) | 中分山天寨洋馆，战后五年四月，一场开七天的会议——你是听差。 | 简单模拟，可供试手 | 46 KB ｜ 约 10 分钟 ｜ 北沙外传 |
| 04 | [命途转盘 · 启示录教团国](https://darkcoffin-game.hubingsf.cn/jiaotuan.html) | 在教团国里过完一生：从入学到入土，十二签一轮，命途之轮转一生。 | 人生之旅，仅供参考 | 310 KB ｜ 十二签一轮 ｜ 卷二 · 教团国 |

### 四件的关系

* **命途转盘**（北沙 · 教团国）：一个系列，同一套「命途之轮十二签 · 一命」的骨架，
  一局就是一生。教团国是卷二、早期版本；北沙是卷四、后来做得更厚的一件。
* **和平会议 · 七日**：《北沙》的外传——同一片北沙、同一个月份，换一个位置（听差）。
* **戡乱政府 · 用印五日**：独立小件，取材于同一段时期的北沙。全作只有一个动词：用印。

### 建议顺序

1. 《和平会议 · 七日》——十分钟，先熟悉这套纸墨界面
2. 《用印五日》——五分钟，最短，也最容易记住
3. 《命途转盘 · 北沙》——正餐，留出一小时
4. 《命途转盘 · 启示录教团国》——早期版本，当参考看

---

## 技术说明

* **单文件**：每件作品就是一个 `.html`，双击即玩，不需要构建、不需要联网。
* **零外部资源**：没有 CDN、没有图片文件、没有 emoji。纸张、印章、四芒星图标都是排版画的；
  四个作品的标签页图标是内联 SVG。
* **两端都成立**：布局判定是一个纯函数 `layoutFor(宽, 高)`，分三套版式——
  竖屏（手机／平板竖）、横屏矮屏（手机横放）、大屏。已经覆盖 `dvh` 回退、iOS 安全区、
  去掉双击缩放的 300ms 延迟、44px 最小命中区。
* **不保存进度**：没有 localStorage、没有账号，刷新即重来。

## 本地预览

仓库根目录的 `serve.py` 是一个本地静态服务器（**未纳入发布**，`.gitignore` 已排除）：

```powershell
python serve.py            # http://127.0.0.1:8000 ，带请求日志
python serve.py --check    # 不打开浏览器，把整站链接抓一遍并打印状态码
```

`--check` 会**按逐字节大小写**核对文件名——Windows 不区分大小写而 GitHub Pages（Linux）
区分，`href="Yongyin.html"` 在本机正常、推上去就 404，这一步专门防它。

## 更新与发布

本站用 **SSH** 推送。**不需要 token，也不需要切换账号**：

```powershell
cd 'E:\黑柩\黑柩游戏'
git add -A
git commit -m "update site"
git push
```

本机已经配好：`~/.ssh/config` 里为这个账号单独配了一个 Host 别名，remote 走的是它
（`git@github-game:darkcoffin-game/darkcoffin-game.github.io.git`）——所以同一台机器上
共存多个 GitHub 账号也不会互相串。

**换机器时**才需要重新配一次：`ssh-keygen -t ed25519` → 把 `.pub` 加到
GitHub → Settings → SSH and GPG keys，再 `git remote set-url origin <SSH 地址>`。

> **别用 `ssh -T git@github.com` 判断通不通。** 多账号共存的机器上它**必然**报
> `Permission denied (publickey)`——因为它用的是默认密钥，而本仓库走的是配置里的
> Host 别名。真正的判据是这两条：
>
> ```powershell
> git ls-remote origin      # 读通了吗
> git push --dry-run        # 写权限有了吗（不会真的推）
> ```

> `push-with-token.ps1` 是**改用 SSH 之前的方案**（用 Personal Access Token 推），
> 现在只在"某台机器上没有 SSH 密钥"时当备用。它记录的两个教训仍然有效：
> Windows 的凭据**按主机名存、只有一份**（换账号必须先删旧的）；浏览器 OAuth 会继承
> 已登录的账号，所以认证要走 token 而不是浏览器弹窗。脚本刻意写成**纯 ASCII**——
> PowerShell 5.1 读无 BOM 的脚本按 ANSI/GBK 解析，中文注释会被搞乱。

## 目录结构

```
index.html            首页：四张卡片、进站警告、先玩哪个
404.html              查无此页（Pages 上直接访问不存在的路径时用）
yongyin.html          01 戡乱政府 · 用印五日
beisha.html           02 命途转盘 · 北沙 · 白色恐怖
qiri.html             03 和平会议 · 七日
jiaotuan.html         04 命途转盘 · 启示录教团国
icon.png              站点图标（标签页／iOS 主屏）
CNAME                 自定义域名：darkcoffin-game.hubingsf.cn
.nojekyll             让 GitHub Pages 不跑 Jekyll
.gitattributes        关掉 Windows 的 LF↔CRLF 自动转换，避免假改动
.gitignore            排除 serve.py 与系统垃圾文件
push-with-token.ps1   备用：改用 SSH 之前的 PAT 推送脚本（见上）
serve.py              本地预览（不入库）
```

> 首页上的**体量与「最近更新」日期是从各作品的真实文件生成的**，不手写——
> 手写的数字迟早会说谎。更新作品后请同步刷新首页的这一处。

---

## 友情链接

* [黑柩创作站](https://darkcoffin.hubingsf.cn) —— 原作者的黑柩企划官网
* [黑柩 Wiki](https://darkcoffin-wiki.hubingsf.cn) —— 设定站 · 跑团站 · 花絮站 · 分析站

## 声明

本仓库内容由 **AI 生成**，非原作者发布，不代表原作者立场。
《黑柩》相关内容版权归原作者所有。
