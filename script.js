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

// ===== 批注系统功能 =====
document.addEventListener('DOMContentLoaded', () => {
  // 为所有批注目标添加交互效果
  const annotationTargets = document.querySelectorAll('.annotation-target');
  
  annotationTargets.forEach(target => {
    const svg = target.querySelector('.annotation-svg');
    if (svg) {
      // 悬停时显示批注
      target.addEventListener('mouseenter', () => {
        const lines = svg.querySelectorAll('.annotation-line');
        const circles = svg.querySelectorAll('.annotation-circle');
        
        lines.forEach(line => {
          line.style.opacity = '1';
          line.style.animation = 'drawLine 0.6s ease-in-out';
        });
        
        circles.forEach(circle => {
          circle.style.strokeWidth = '3';
          circle.style.filter = 'drop-shadow(0 4px 8px rgba(233, 180, 131, 0.6))';
        });
      });

      target.addEventListener('mouseleave', () => {
        const lines = svg.querySelectorAll('.annotation-line');
        const circles = svg.querySelectorAll('.annotation-circle');
        
        lines.forEach(line => {
          line.style.opacity = '0.7';
        });
        
        circles.forEach(circle => {
          circle.style.strokeWidth = '2.5';
          circle.style.filter = 'drop-shadow(0 2px 4px rgba(233, 180, 131, 0.4))';
        });
      });
    }
  });

  // 指针框点击滚动到目标
  const pointerBoxes = document.querySelectorAll('.pointer-box');
  pointerBoxes.forEach(box => {
    if (box.onclick) return; // 跳过已有 onclick 的元素
    
    box.addEventListener('click', () => {
      const targetId = box.getAttribute('data-target');
      if (targetId) {
        const target = document.getElementById(targetId);
        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'center' });
          // 添加高亮效果
          target.style.animation = 'pulse 0.6s ease-in-out';
        }
      }
    });
  });
});

// 脉冲动画
const style = document.createElement('style');
style.textContent = `
  @keyframes pulse {
    0%, 100% { background-color: #f9fafb; }
    50% { background-color: rgba(233, 180, 131, 0.3); }
  }
  
  @keyframes drawLine {
    from {
      stroke-dashoffset: 100;
      opacity: 0;
    }
    to {
      stroke-dashoffset: 0;
      opacity: 1;
    }
  }
`;
document.head.appendChild(style);
