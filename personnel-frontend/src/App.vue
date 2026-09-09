<template>
  <router-view />
  <div class="app-watermark" aria-hidden="true" :style="{ backgroundImage: wmBg }"></div>
</template>

<script setup>
// 全局表层水印：斜向浅色文字 github:Schicksal（纯装饰层，不拦截任何鼠标/键盘事件）
const wmSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="560" height="380" viewBox="0 0 560 380">
  <g fill="#5c6c80" font-family="Microsoft YaHei, PingFang SC, Arial, sans-serif" font-size="22">
    <text x="70" y="95" transform="rotate(-24 70 95)">github:Schicksal</text>
    <text x="320" y="215" transform="rotate(-24 320 215)">github:Schicksal</text>
    <text x="55" y="315" transform="rotate(-24 55 315)">github:Schicksal</text>
  </g>
</svg>`
const wmBg = `url("data:image/svg+xml;utf8,${encodeURIComponent(wmSvg)}")`
</script>

<style>
.app-watermark {
  position: fixed;
  inset: 0;
  z-index: 9999;
  pointer-events: none;
  opacity: 0.09;
  background-repeat: repeat;
}
</style>
