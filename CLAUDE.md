# 血压笔记 (Blood Pressure Notes)

一个 PWA（渐进式网页应用），用于记录和追踪血压数据。纯前端，所有数据存储在浏览器的 IndexedDB 中，不上传任何服务器。

**线上地址**: https://fengege190.github.io/bp-app/

---

## 新电脑准备工作

要在新电脑上开始开发，需要先装好以下工具：

### 1. Git（版本控制）

```
下载安装：https://git-scm.com/downloads
安装选项：全部默认即可
```

安装完成后，打开命令提示符，配置用户名和邮箱（和 GitHub 账号一致）：

```bash
git config --global user.name "你的GitHub用户名"
git config --global user.email "你的GitHub邮箱"
```

验证是否装好：

```bash
git --version
# 应该显示 git version 2.x.x
```

### 2. VS Code（代码编辑器）

```
下载安装：https://code.visualstudio.com/
```

装好后安装以下插件（按 Ctrl+Shift+X 打开扩展搜索）：
- **Live Server** — 右键 HTML 文件即可启动本地服务器
- **Chinese Language Pack** — 中文界面（可选）
- **GitLens** — 在代码中查看 Git 历史（可选）

### 3. Python（用于启动本地 HTTP 服务器）

```
下载安装：https://www.python.org/downloads/
安装时务必勾选 "Add Python to PATH"
```

验证：

```bash
python --version
# 应该显示 Python 3.x.x
```

### 4. 浏览器（用于测试）

推荐 **Chrome** 或 **Edge**，用来看效果和调试。

**F12 开发工具常用功能：**
- **Console** — 看报错信息
- **Application → IndexedDB** — 查看/删除浏览器数据
- **Application → Service Workers** — 管理离线缓存
- **Network** — 看网络请求

### 5. （可选）Node.js

如果以后需要用到本地隧道（localtunnel）让外网访问，才需要装：

```
下载安装：https://nodejs.org/
验证：node --version
```

### 6. （可选）Flutter SDK

如果想编译安卓 APK，才需要配置。过程比较复杂（需安装 Flutter SDK + Java JDK + Android Studio），建议先熟悉了网页版再搞。

---

## 第一次在新电脑上运行项目

打开命令提示符，执行以下命令：

```bash
# 1. 下载代码
git clone https://github.com/fengege190/bp-app.git

# 2. 进入项目目录
cd bp-app

# 3. 启动本地服务器
python -m http.server 8080
```

然后打开浏览器访问 **http://localhost:8080** 就能看到应用。

如果需要修改代码，用 VS Code 打开 `bp-app` 文件夹：

```bash
code .
```

---

## 日常开发流程

```bash
# 1. 先拉取最新代码（在别的电脑修改过的话）
git pull

# 2. 修改 index.html 或其它文件
# （用 VS Code 编辑）

# 3. 保存文件，回到浏览器刷新看效果
# （如果用了 Live Server，会自动刷新）

# 4. 提交并上传到 GitHub
git add .
git commit -m "简单说明改了什么东西"
git push
```

> **第一次 `git push` 会弹出 GitHub 登录窗口**，用 fengege190 账号登录即可。
> 之后 Pages 会自动更新，等 1-2 分钟访问 https://fengege190.github.io/bp-app/ 就能看到最新版本。

---

## 技术栈

- **单文件架构**: 所有代码在 `index.html` 一个文件里（HTML + CSS + JS）
- **存储**: 浏览器 IndexedDB（`bp_db` 数据库，`records` 表）
- **图表**: Canvas API 手绘折线图（无第三方依赖）
- **PWA**: Service Worker（`sw.js`）+ Manifest（`manifest.json`），支持离线使用
- **部署**: GitHub Pages（自动从 main 分支根目录部署）

---

## 项目结构

```
bp-app/
├── CLAUDE.md              # 本文件 — 给 Claude 的项目说明
├── index.html             # 主应用（全部代码在这里 ~42KB）
├── manifest.json          # PWA 配置（应用名、图标、主题色）
├── sw.js                  # Service Worker（离线缓存策略）
├── gen_icons.ps1          # 生成 PWA 图标的 PowerShell 脚本
├── icons/                 # PWA 图标（icon-192.png, icon-512.png）
│
├── web_app/               # ⚠ 已废弃的旧目录，与根目录文件重复
│                           # 可以在 GitHub 网页上手动删除
│
├── android/               # Flutter 安卓项目（未编译）
├── ios/                   # Flutter iOS 项目（未编译）
├── lib/                   # Flutter Dart 源代码
├── test/                  # Flutter 测试
├── pubspec.yaml           # Flutter 依赖配置
```

> **开发网页版只需要关注根目录那 4 个文件（index.html, manifest.json, sw.js, icons/）**，Flutter 文件是之前生成的移动端源码，暂时不需要管。

---

## 本地开发

### 方法一：直接打开（最简单）

直接把 `index.html` 拖到浏览器里就能用。数据会保存在浏览器的 IndexedDB 里。

### 方法二：本地服务器（推荐，支持 Service Worker）

```bash
# 用 Python 启动一个简单的 HTTP 服务器
python -m http.server 8080
# 然后访问 http://localhost:8080
```

### 方法三：VS Code Live Server

安装 Live Server 插件，右键 `index.html` → Open with Live Server。

---

## 核心逻辑

### 血压分类（`classifyBP` 函数）

| 收缩压 | 舒张压 | 分类 | 颜色 |
|--------|--------|------|------|
| < 120 | < 80 | 正常 | 绿色 `#4CAF50` |
| 120-129 | < 80 | 偏高 | 黄色 `#FFC107` |
| 130-139 | 80-89 | 高血压1级 | 橙色 `#FF9800` |
| ≥ 140 | ≥ 90 | 高血压2级 | 红色 `#F44336` |
| ≥ 180 | ≥ 120 | 高血压危象 | 深红 `#D32F2F` |

### 数据存储（IndexedDB）

- 数据库名: `bp_db`
- 表名: `records`
- 每条记录字段: `id`, `date`, `timestamp`, `systolic`, `diastolic`, `heartRate`, `notes`
- 索引: `date`（日期）、`timestamp`（时间戳）
- 所有操作在 `index.html` 的 `<script>` 中，函数名见下方

### 关键函数

| 函数 | 作用 |
|------|------|
| `openDB()` | 打开 IndexedDB 连接 |
| `getAllRecords()` | 获取所有记录（按时间倒序） |
| `addRecord(record)` | 添加新记录 |
| `updateRecord(record)` | 更新记录 |
| `deleteRecord(id)` | 删除记录 |
| `clearAllRecords()` | 清空全部数据 |
| `classifyBP(s, d)` | 血压分类 |
| `renderHome()` | 渲染首页 |
| `navigate(page, data)` | 切换页面 |
| `saveRecord(e)` | 保存表单 |
| `exportCSV()` | 导出 CSV |

---

## 页面结构

应用有 5 个页面（SPA 切换）:

1. **首页**（home）— 最新血压卡片 + 最近记录列表 + 快捷统计
2. **记录**（record）— 表单输入血压/心率，实时预览分类
3. **历史**（history）— 按日期分组的全部记录，可删除
4. **趋势**（charts）— 折线图 + 统计卡片，支持周/月/季切换
5. **设置**（settings）— 关于信息 + 导出 CSV + 清空数据

---

## 部署

### GitHub Pages（已配置）

修改 `index.html` 后提交到 main 分支，GitHub Pages 会自动更新：

```bash
git add index.html
git commit -m "修改了 xxx"
git push
```

等 1-2 分钟，访问 https://fengege190.github.io/bp-app/ 就能看到更新。

---

## 常见开发任务

### 1. 添加新功能（比如加个字段）

1. 在 `initRecordForm()` 中增加表单输入
2. 在 `saveRecord()` 中读取新字段
3. IndexedDB 会自动存储新字段（NoSQL 模式）

### 2. 修改样式

所有 CSS 在 `index.html` 的 `<style>` 标签里，使用 CSS 变量（`:root`）控制主题色。

### 3. 修改图表

折线图用 Canvas API 绘制，代码在 `renderChart()` 函数中。

### 4. 国际化

标题和按钮文字散落在 HTML 和 JS 中，搜索对应文字修改即可。

---

## 注意事项

1. **数据在本地**：IndexedDB 是浏览器本地数据库，清除浏览器缓存会丢失数据。如需备份，用"导出 CSV"功能。
2. **没有后端**：纯前端应用，无服务器、无数据库、无 API。所有逻辑在浏览器中执行。
3. **GitHub Pages 缓存**：更新部署后可能需要 1-2 分钟生效，Ctrl+F5 强制刷新。
4. **Flutter 项目**：`android/`、`lib/` 等目录是之前生成的 Flutter 源码，目前未编译，**不建议手动修改**。如需开发 Flutter 版本需要安装 Flutter SDK + Android SDK。
5. **Service Worker**：离线缓存策略是 cache-first，开发时修改 `index.html` 后可能需要打开 DevTools → Application → Service Workers → 勾选 "Bypass for network" 才能看到最新效果。

---

## 关于 Claude Code

如果你是 Claude Code（claude.ai/code），以下是对你有用的信息：

### 项目背景
- 这是一个**纯前端 PWA 项目**，所有功能在一个 `index.html` 中
- 用户**没有编程基础**，需要你直接帮他修改代码，他负责测试
- 项目当前工作正常，线上的 GitHub Pages（https://fengege190.github.io/bp-app/）已经部署成功
- 用户 GitHub 账号：**fengege190**，仓库：**bp-app**
- 这是从零开始一步步建起来的项目，用户已了解基本用法

### 开发建议
- 要预览修改效果，优先使用 `python -m http.server 8080` 启动本地服务器
- 修改完成后的提交流程：`git add . && git commit -m "说明" && git push`
- 如果用户想给 App 加新功能，优先修改 `index.html` 中的对应函数
- Flutter 相关文件（`android/`, `lib/` 等）暂时不需要处理
- Google Chrome 的 F12 开发者工具是调试首选

### 已走过的弯路（避免再犯）
1. 用户发图片时直接说"我看不了图片"即可，不要问他要截图
2. 不要试图用 gh CLI 操作 GitHub（自动模式限制），改用 GitHub 网页界面或 API
3. 不要用 PowerShell 脚本（`.ps1`），用户电脑的执行策略可能阻止运行，优先用 cmd 或直接操作
4. 编译 APK 之前需要先确认 Java JDK、Android SDK 是否已安装

### 第一条指令：执行步骤

当用户在新电脑上第一次打开 Claude Code 说"继续开发血压笔记"时，按以下顺序执行：

**步骤 1：检查环境**
```bash
git --version        # 确认 Git 已安装
python --version     # 确认 Python 已安装
code --version       # 确认 VS Code 已安装（可选）
```

如果哪个没装，先让用户去下载安装（下载链接见上方"新电脑准备工作"）。

**步骤 2：克隆代码（如果还没克隆）**
```bash
git clone https://github.com/fengege190/bp-app.git
cd bp-app
```

**步骤 3：启动本地服务器**
```bash
python -m http.server 8080
```
然后在浏览器打开 http://localhost:8080 确认应用能正常运行。

**步骤 4：告诉用户一切就绪**
通知用户：开发环境已配置好，可以开始修改功能了。

**之后每次用户提需求：**
1. 先 `git pull` 拉取最新代码
2. 修改 `index.html`
3. 让用户在浏览器刷新看效果
4. 确认没问题后 `git add . && git commit -m "说明" && git push`

### 项目历史
- 最初想做一个安卓 App → 先用 Flutter 写了代码但无法编译
- 转而做了一个网页版 PWA，目前已上线可用
- 网页版测试过 localtunnel（临时外网访问）和 GitHub Pages（正式部署）
- GitHub Pages 目前工作正常
