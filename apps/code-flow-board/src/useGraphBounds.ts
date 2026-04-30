import { useMemo } from "react";
import type { BoardNode } from "./types";

export function useGraphBounds(nodes: BoardNode[] | undefined) {
  const nodeSignature = nodes?.map((node) => `${node.id}:${node.width}:${node.height}`).join("|") ?? "";
  return useMemo(() => {
    if (!nodes?.length) return { minX: 0, minY: 0, width: 900, height: 620 };
    const pad = 180;
    const minX = Math.min(...nodes.map((node) => node.x)) - pad;
    const minY = Math.min(...nodes.map((node) => node.y - (node.sequence ? 34 : 0))) - pad;
    const maxX = Math.max(...nodes.map((node) => node.x + node.width)) + pad;
    const maxY = Math.max(...nodes.map((node) => node.y + node.height + 18)) + pad;
    return { minX, minY, width: Math.max(900, maxX - minX), height: Math.max(620, maxY - minY) };
  }, [nodeSignature]);
}
