# SuyuOri.github.io

一个极简风格的静态个人网站，作为 GitHub Pages 的初始版本。包含基本的介绍、计划和联系方式版块，同时保持结构简单，方便后续扩展。

## 功能

- 响应式的单页布局，适配桌面与移动端
- Hero 区域带有互动按钮，可随机展示问候语
- 独立的 `styles.css` 和 `script.js` 便于继续扩展
- 使用 `html-validate` 进行基础的 HTML 质量检查

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
