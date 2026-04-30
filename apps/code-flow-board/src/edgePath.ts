import type { BoardEdge, BoardNode } from "./types";

export function pathFor(edge: BoardEdge, nodes: BoardNode[]) {
  if (edge.points.length >= 2) {
    return edge.points.map((point, index) => `${index === 0 ? "M" : "L"} ${point.x} ${point.y}`).join(" ");
  }
  const from = nodes.find((node) => node.id === edge.from);
  const to = nodes.find((node) => node.id === edge.to);
  if (!from || !to) return "";
  const start = { x: from.x + from.width / 2, y: from.y + visualHeight(from) };
  const end = { x: to.x + to.width / 2, y: to.y };
  const midY = start.y + Math.max(72, (end.y - start.y) / 2);
  return `M ${start.x} ${start.y} L ${start.x} ${midY} L ${end.x} ${midY} L ${end.x} ${end.y}`;
}

export function edgeLabelPoint(edge: BoardEdge, nodes: BoardNode[]) {
  if (edge.points.length >= 2) {
    const middle = edge.points[Math.floor(edge.points.length / 2)];
    return { x: middle.x, y: middle.y };
  }
  const from = nodes.find((node) => node.id === edge.from);
  const to = nodes.find((node) => node.id === edge.to);
  if (!from || !to) return { x: 0, y: 0 };
  return {
    x: (from.x + from.width / 2 + to.x + to.width / 2) / 2,
    y: from.y + visualHeight(from) + Math.max(72, (to.y - from.y - visualHeight(from)) / 2),
  };
}

function visualHeight(node: BoardNode) {
  return node.height + 18;
}
