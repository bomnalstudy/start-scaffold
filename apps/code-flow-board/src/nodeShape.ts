import type { BoardNode } from "./types";

export function shapePath(node: BoardNode) {
  const { x, y, width: w, height: h } = node;
  if (node.kind === "decision") return `M ${x + w / 2} ${y} L ${x + w} ${y + h / 2} L ${x + w / 2} ${y + h} L ${x} ${y + h / 2} Z`;
  if (node.kind === "data") return `M ${x} ${y + 12} C ${x} ${y - 4}, ${x + w} ${y - 4}, ${x + w} ${y + 12} L ${x + w} ${y + h - 12} C ${x + w} ${y + h + 4}, ${x} ${y + h + 4}, ${x} ${y + h - 12} Z M ${x} ${y + 12} C ${x} ${y + 28}, ${x + w} ${y + 28}, ${x + w} ${y + 12}`;
  if (node.kind === "io") return `M ${x + 22} ${y} H ${x + w} L ${x + w - 22} ${y + h} H ${x} Z`;
  if (node.kind === "document") return `M ${x} ${y} H ${x + w} V ${y + h - 14} C ${x + w * 0.72} ${y + h + 8}, ${x + w * 0.25} ${y + h - 24}, ${x} ${y + h} Z`;
  return "";
}
