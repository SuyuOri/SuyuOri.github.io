# SuyuOri.github.io

一个参考 Gatsby Starter Blog 视觉风格打造的静态博客主页。包含 Hero、文章列表、侧边栏（个人简介 / 标签 / Newsletter）等模块，并保持结构清晰，方便继续扩展内容源。

## 功能

- 响应式博客布局，包含文章卡片 + 侧边栏
- Hero 模块支持随机灵感提示按钮，贴近 Gatsby 的互动体验
- 侧边栏集成标签云和 Newsletter 表单（前端校验）
- 新增“文件夹”结构，可折叠查看草稿、日志、片段等分类
- 集成 `favicon_io` 生成的一整套 PWA 图标（apple-touch-icon、PNG、ICO、manifest）
- 独立的 `styles.css` 和 `script.js` 便于继续扩展
- 使用 `html-validate` 进行基础的 HTML 质量检查
- `blog/ppo-code-walkthrough.typ` + `ppo.html` 组成首篇技术稿：Typst 源稿 + 站内独立阅读页

## 本地预览

```bash
npm install
npm run dev
```

> 该命令会使用 `serve` 在 <http://localhost:4173> 打开静态站点，如需关闭按下 `Ctrl+C`。

## 质量检查

```bash
npm run lint
```

## 部署

将本仓库推送到 `main`（或 `master`）分支后，GitHub Pages 会自动发布 `index.html`。如果你使用的是 `SuyuOri/SuyuOri.github.io` 仓库，默认域名为 <https://SuyuOri.github.io>。

## Typst 博客草稿

1. [安装 Typst](https://typst.app/docs/install/) 或使用命令行 `cargo install typst-cli`。
2. 在仓库根目录运行：

	```bash
	typst compile blog/ppo-code-walkthrough.typ blog/ppo-code-walkthrough.pdf
	```

3. 生成的 PDF 即为《PPO 代码解读》初稿，可上传到发布渠道或嵌入网页。
4. 首页 `index.html` 中的 “PPO 代码解读” 卡片会跳转到 `ppo.html`；该页面直接展示正文并附带下载 Typst 源文件的入口。
