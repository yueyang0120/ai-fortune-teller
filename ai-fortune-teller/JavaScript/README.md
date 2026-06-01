# JavaScript Integration - iztro 库

## 获取 iztro.js

iztro 是一个开源的紫微斗数 JavaScript 库，需要将其打包并集成到 iOS 项目中。

### 方法 1: 使用 npm 安装并打包

```bash
# 1. 安装 iztro
npm install iztro

# 2. 创建一个 bundle.js 文件
npx webpack --entry ./node_modules/iztro/dist/index.js --output-path ./JavaScript --output-filename iztro.bundle.js
```

### 方法 2: 使用 CDN 下载

```bash
# 从 unpkg CDN 下载
curl https://unpkg.com/iztro@latest/dist/iztro.min.js -o JavaScript/iztro.bundle.js
```

### 方法 3: 直接从 GitHub 获取

访问 https://github.com/SylarLong/iztro 并下载 dist 目录下的文件。

## 使用说明

将下载的 iztro.bundle.js 文件放置在本项目的 `JavaScript/` 目录下，然后在 Xcode 中：

1. 将 iztro.bundle.js 添加到项目
2. 确保文件在 "Copy Bundle Resources" 中
3. ZiWeiChartService 会自动加载并使用该文件

## iztro 库文档

- GitHub: https://github.com/SylarLong/iztro
- 文档: https://docs.iztro.com/
- API 参考: https://docs.iztro.com/api/

## 示例用法

```javascript
// 生成命盘
const astrolabe = astro.astrolabe({
  solar: '2000-8-16',
  hour: 2,
  minute: 30,
  gender: 'female',
  fixLeap: true
});

// 获取命盘信息
console.log(astrolabe.fiveElementsClass); // 五行局
console.log(astrolabe.palace('命宫')); // 命宫信息
```
