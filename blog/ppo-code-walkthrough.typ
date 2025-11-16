#import "@preview/codelst:0.3.1": listing

#set page(width: 148mm, height: 210mm)
#set text(font: "Space Grotesk", size: 11pt)

#show heading.where(level: 1): set text(size: 18pt, weight: 600)
#show heading.where(level: 2): set text(size: 14pt, weight: 600)
#show heading.where(level: 3): set text(size: 12pt, weight: 600)

#let pill(label) = box(fill: rgb("f2f7ff"), inset: (x: 8pt, y: 4pt), radius: 6pt)[#text(size: 9pt, weight: 600, label)]

= Proximal Policy Optimization (PPO) — 代码解读

[pill("Draft · 2025-11-16")]
[pill("Reinforcement Learning"), pill("Typst Blog Prototype")]

== 为什么选择 PPO？
PPO 通过限制策略更新的幅度，兼顾了 **训练稳定性** 与 **样本效率**。它使用裁剪目标(clipped objective)来避免策略在单次更新中偏离旧策略太多，进而减少了早期 TRPO 需要的二阶优化复杂度。

我们从损失函数入手：

$L^{CLIP}(\theta) = \mathbb{E}_t\left[ \min( r_t(\theta) \hat{A}_t, \text{clip}(r_t(\theta), 1-\epsilon, 1+\epsilon) \hat{A}_t ) \right]$

其中 $r_t(\theta) = \frac{\pi_\theta(a_t|s_t)}{\pi_{\theta_{old}}(a_t|s_t)}$，$\hat{A}_t$ 为广义优势估计(GAE)。

== 算法流程
1. 采集 $N$ 条轨迹，得到 $(s_t, a_t, r_t)$。
2. 使用 GAE 估计优势：
   $\hat{A}_t = \sum_{l=0}^{T-t} (\gamma\lambda)^l \delta_{t+l}$。
3. 计算裁剪目标并进行多轮 epoch + mini-batch 更新。
4. 同时最小化 value 函数误差和熵惩罚，保持探索。

== 关键代码
下面是一段使用 PyTorch 实现的 PPO 更新伪代码，突出裁剪比率与多 epoch 训练：

#listing(lang: "python", title: "ppo_update.py")
```python
for epoch in range(update_epochs):
    minibatches = rollout.sample_batches(batch_size)
    for batch in minibatches:
        obs, act, old_logp, returns, adv = batch

        logp, value = policy.evaluate(obs, act)
        ratio = (logp - old_logp).exp()

        unclipped = ratio * adv
        clipped = ratio.clamp(1 - clip_coef, 1 + clip_coef) * adv
        policy_loss = -torch.min(unclipped, clipped).mean()

        value_loss = 0.5 * (returns - value).pow(2).mean()
        entropy_loss = -entropy_coef * policy.entropy(obs).mean()

        loss = policy_loss + value_coef * value_loss + entropy_loss
        optimizer.zero_grad()
        loss.backward()
        torch.nn.utils.clip_grad_norm_(policy.parameters(), 0.5)
        optimizer.step()
```

== 进一步的工程笔记
- **Advantage 标准化**：训练时常对 $\hat{A}_t$ 做零均值单位方差归一化，防止比率放大。
- **学习率调度**：在总的训练步中做线性退火，配合 clip 范围可以更稳定。
- **复现细节**：确保 rollout buffer 里保存 old logits；同时 value 目标要加上可选的 clip。

== 下一步
- 将本 Typst 草稿导出为 PDF：
  ```bash
  typst compile blog/ppo-code-walkthrough.typ blog/ppo-code-walkthrough.pdf
  ```
- 未来可将此文与网页联动，例如在网站中嵌入导出的 PDF，或使用 Typst 生成 HTML 片段。
