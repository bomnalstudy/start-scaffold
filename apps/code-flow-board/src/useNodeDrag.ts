import { useState, type Dispatch, type PointerEvent, type SetStateAction } from "react";
import type { BoardNode } from "./types";
import type { layoutFlow } from "./layout";

type LayoutState = Awaited<ReturnType<typeof layoutFlow>>;

export function useNodeDrag(
  setLayout: Dispatch<SetStateAction<LayoutState | null>>,
  setSelected: Dispatch<SetStateAction<string>>,
) {
  const [dragNode, setDragNode] = useState<{ id: string; x: number; y: number; nodeX: number; nodeY: number } | null>(null);

  function pointerPoint(event: PointerEvent<SVGGElement>) {
    const svg = event.currentTarget.ownerSVGElement;
    if (!svg) return { x: event.clientX, y: event.clientY };
    const point = svg.createSVGPoint();
    point.x = event.clientX;
    point.y = event.clientY;
    const matrix = svg.getScreenCTM()?.inverse();
    if (!matrix) return { x: event.clientX, y: event.clientY };
    const next = point.matrixTransform(matrix);
    return { x: next.x, y: next.y };
  }

  function startNodeDrag(event: PointerEvent<SVGGElement>, node: BoardNode) {
    event.stopPropagation();
    event.currentTarget.setPointerCapture(event.pointerId);
    setSelected(node.id);
    const point = pointerPoint(event);
    setDragNode({ id: node.id, x: point.x, y: point.y, nodeX: node.x, nodeY: node.y });
  }

  function moveNode(event: PointerEvent<SVGGElement>, node: BoardNode) {
    if (!dragNode || dragNode.id !== node.id) return;
    event.stopPropagation();
    const point = pointerPoint(event);
    const dx = point.x - dragNode.x;
    const dy = point.y - dragNode.y;
    setLayout((current) => {
      if (!current) return current;
      return {
        ...current,
        nodes: current.nodes.map((item) => item.id === node.id ? { ...item, x: dragNode.nodeX + dx, y: dragNode.nodeY + dy } : item),
        edges: current.edges.map((edge) => edge.from === node.id || edge.to === node.id ? { ...edge, points: [] } : edge),
      };
    });
  }

  return {
    draggingId: dragNode?.id,
    startNodeDrag,
    moveNode,
    stopNodeDrag: () => setDragNode(null),
  };
}
