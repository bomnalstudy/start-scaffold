import type { BoardEdge, BoardNode } from "./types";

export function pathFor(edge: BoardEdge, nodes: BoardNode[]) {
  const from = nodes.find((node) => node.id === edge.from);
  const to = nodes.find((node) => node.id === edge.to);
  if (!from || !to) return "";
  const start = { x: from.x + from.width / 2, y: from.y + from.height };
  const end = { x: to.x + to.width / 2, y: to.y };
  const midY = start.y + Math.max(42, (end.y - start.y) / 2);
  return `M ${start.x} ${start.y} L ${start.x} ${midY} L ${end.x} ${midY} L ${end.x} ${end.y}`;
}

export function edgeLabelPoint(edge: BoardEdge, nodes: BoardNode[]) {
  const from = nodes.find((node) => node.id === edge.from);
  const to = nodes.find((node) => node.id === edge.to);
  if (!from || !to) return { x: 0, y: 0 };
  return {
    x: (from.x + from.width / 2 + to.x + to.width / 2) / 2,
    y: from.y + from.height + Math.max(42, (to.y - from.y - from.height) / 2),
  };
}
