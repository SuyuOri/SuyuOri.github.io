const helloButton = document.getElementById("helloButton");
const helloMessage = document.getElementById("helloMessage");
const yearEl = document.getElementById("year");

const greetings = [
  "很高兴见到你！",
  "祝你今天保持灵感",
  "欢迎常来坐坐",
  "愿每一行代码都顺利",
];

helloButton?.addEventListener("click", () => {
  const message = greetings[Math.floor(Math.random() * greetings.length)];
  helloMessage.textContent = message;
  helloMessage.classList.add("shown");
});

yearEl.textContent = new Date().getFullYear();
