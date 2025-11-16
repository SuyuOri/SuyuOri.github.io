#set page(width: 148mm, height: 210mm, margin: (top: 2cm, bottom: 2cm, left: 1.5cm, right: 1.5cm))
#set text(font: "Space Grotesk", size: 11pt, lang: "zh")

// 标题样式设置
#show heading.where(level: 1): it => {
  set text(size: 18pt, weight: 700, font: "Merriweather")
  v(0.5em)
  it
  v(0.3em)
}
#show heading.where(level: 2): it => {
  set text(size: 14pt, weight: 600)
  v(0.4em)
  it
  v(0.2em)
}
#show heading.where(level: 3): set text(size: 12pt, weight: 600)

// 代码块样式
#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 12pt,
  radius: 6pt,
  width: 100%,
)

#let pill(label) = box(
  fill: rgb("e9b483"),
  inset: (x: 8pt, y: 4pt),
  radius: 4pt,
)[#text(size: 9pt, weight: 600, fill: white, label)]

#let info-box(content) = block(
  fill: rgb("eef5ff"),
  inset: 12pt,
  radius: 8pt,
  stroke: (left: 3pt + rgb("4f7398")),
)[#content]

// ===== 高级注释功能 =====

// 圈出并标注关键词
#let highlight-term(term, color: rgb("e9b483")) = box(
  stroke: 2pt + color,
  radius: 8pt,
  inset: (x: 6pt, y: 3pt),
  fill: rgba(233, 180, 131, 15%),
)[#text(weight: 600, term)]

// 带标号的代码片段 - 用于交叉引用
#let code-label(content, label, color: rgb("4f7398")) = {
  block(
    width: 100%,
    inset: 0pt,
    [
      #set text(size: 10pt, fill: color, weight: 600)
      ◀ #label
      #block(
        width: 100%,
        inset: 12pt,
        fill: luma(245),
        radius: 6pt,
        stroke: (left: 3pt + color),
      )[
        #content
      ]
    ]
  )
}

// 可视化指针 - 指向相关代码
#let pointer(label, target) = box(
  inset: (x: 8pt, y: 4pt),
  radius: 4pt,
  fill: rgba(79, 115, 152, 10%),
  stroke: 1pt + rgb("4f7398"),
)[
  #text(size: 9pt, [*→ #label*]) #h(2pt) #text(size: 8pt, fill: rgb("666"), [@#target])
]

= Proximal Policy Optimization — 代码解读

#align(center)[
  [pill("Draft · 2025-11-16")]
  [pill("RL"), pill("PyTorch"), pill("Typst")]
]

== 为什么选择 PPO？

PPO 通过限制策略更新的幅度，在 #highlight-term("训练稳定性") 和 *样本效率* 之间找到了平衡。相比早期的 TRPO，它避免了昂贵的二阶优化，使用更简洁的裁剪目标(clipped objective)。

#pointer("见代码片段 A", "clip-loss")
#pointer("见代码片段 B", "ratio-calc")

我们从损失函数入手：

#align(center)[
  $L^"CLIP"(theta) = bb(E)_t [min(r_t(theta) hat(A)_t, "clip"(r_t(theta), 1-epsilon, 1+epsilon) hat(A)_t)]$
]

其中：
- $r_t(theta) = pi_theta(a_t|s_t) / pi_{theta_"old"}(a_t|s_t)$ 是新旧策略的概率比
- $hat(A)_t$ 是通过 GAE（广义优势估计）计算的优势
- $epsilon$ 是裁剪范围超参数（通常 0.1 ~ 0.2）

== 算法流程

PPO 的训练过程分为几个关键步骤：

+ *数据收集*：采集 $N$ 条轨迹，记录状态、动作和奖励序列 $(s_t, a_t, r_t)$
+ *优势计算*：使用 GAE 估计每个时步的优势：
  #align(center)[
    $hat(A)_t = sum_{l=0}^{T-t} (gamma lambda)^l delta_{t+l}$
  ]
  其中 $delta_t = r_t + gamma V(s_{t+1}) - V(s_t)$ 是 TD 误差
+ *多轮更新*：基于采集的数据进行多个 epoch 的 mini-batch 更新
+ *辅助目标*：同时最小化 value 函数误差和熵惩罚 $L^"VF"$ 和 $L^"ENT"$

== 关键代码

下面是使用 PyTorch 实现的 PPO 单步更新，展示了裁剪技巧和多 epoch 训练的核心逻辑：

#code-label(
  ```python
  for epoch in range(num_updates):
      minibatches = rollout.sample_batches(batch_size)
      for batch in minibatches:
          obs, act, old_logp, returns, adv = batch

          logp, value = policy.evaluate(obs, act)
          ratio = torch.exp(logp - old_logp)
  ```,
  "概率比率计算 (Snippet B)",
  color: rgb("79, 115, 152"),
)

#code-label(
  ```python
          unclipped = ratio * adv
          clipped = torch.clamp(ratio, 1 - clip_eps, 1 + clip_eps) * adv
          
          # ★ 这正是裁剪目标的核心 - 保证训练稳定性 ★
          policy_loss = -torch.min(unclipped, clipped).mean()
  ```,
  "裁剪损失函数 (Snippet A)",
  color: rgb("233, 180, 131"),
)

继续优化过程：

```python
          value_loss = 0.5 * (returns - value).pow(2).mean()
          entropy_bonus = policy.entropy(obs).mean()
          
          loss = policy_loss + vf_coef * value_loss - ent_coef * entropy_bonus
          
          optimizer.zero_grad()
          loss.backward()
          torch.nn.utils.clip_grad_norm_(policy.parameters(), 0.5)
          optimizer.step()
```

== 工程实现细节

#info-box[
  *Advantage 标准化*：在每个更新轮次中，将优势 $hat(A)_t$ 标准化为零均值单位方差，可以有效减少比率爆炸问题。
]

关键改进点：

- *学习率调度*：采用线性退火策略，配合自适应学习率优化器（如 Adam），可显著提升收敛稳定性
- *Batch 划分*：通常采用 mini-batch 重新采样而非全量数据，这既减少显存占用，也增加了随机性
- *Gradient Clipping*：对 $||nabla_theta L||$ 做范数限制（通常 0.5），防止梯度爆炸
- *Value Loss 裁剪*：可选地对 value 损失也进行裁剪，保持与策略更新的一致性
- *熵惩罚权重*：通常采用衰减策略，前期鼓励探索，后期聚焦利用

== 常见问题排查

#table(
  columns: (1fr, 2fr),
  inset: 10pt,
  stroke: luma(200),
  [*症状*], [*可能原因与解决方案*],
  [损失不收敛], [检查学习率是否过高；优势标准化是否正确；clip 范围设置],
  [奖励振荡], [增加 value 函数权重；减小学习率；调整 GAE 参数 $lambda$],
  [模式崩溃], [增加熵惩罚权重；尝试不同的 mini-batch 大小],
)

== 下一步方向

本文档持续迭代中。可尝试：

+ 导出 PDF：`typst compile blog/ppo-code-walkthrough.typ blog/ppo-code-walkthrough.pdf`
+ 实现配套代码：完整的参考实现会另行发布在博客代码段
+ 扩展讨论：分享实际训练的调参经验和踩坑记录

---

#align(center)[
  _Updated: 2025-11-16_
]
