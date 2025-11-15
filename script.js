const ideaButton = document.getElementById("ideaButton");
const ideaMessage = document.getElementById("ideaMessage");
const subscribeForm = document.getElementById("subscribeForm");
const subscribeEmail = document.getElementById("subscribeEmail");
const subscribeMessage = document.getElementById("subscribeMessage");
const yearEl = document.getElementById("year");

const prompts = [
  "写一段关于今天观察到的细节，它会成为故事开端。",
  "挑一张截图，解释你当时为何要保存它。",
  "把最近学到的 3 个概念，用生活化比喻重述。",
  "列出本周让你感到松弛的 5 件小事。",
];

ideaButton?.addEventListener("click", () => {
  const message = prompts[Math.floor(Math.random() * prompts.length)];
  ideaMessage.textContent = message;
});

subscribeForm?.addEventListener("submit", (event) => {
  event.preventDefault();
  const email = subscribeEmail?.value.trim();

  if (!email) {
    subscribeMessage.textContent = "请输入一个有效的邮箱地址。";
    return;
  }

  subscribeMessage.textContent = `谢谢，${email} 将收到下一封更新！`;
  subscribeForm.reset();
});

const folderToggles = document.querySelectorAll(".folder-toggle");

folderToggles.forEach((toggle) => {
  const targetId = toggle.getAttribute("aria-controls");
  const target = document.getElementById(targetId);

  if (!target) return;

  toggle.addEventListener("click", () => {
    const expanded = toggle.getAttribute("aria-expanded") === "true";
    toggle.setAttribute("aria-expanded", String(!expanded));
    target.hidden = expanded;
  });
});

if (yearEl) {
  yearEl.textContent = new Date().getFullYear();
}
