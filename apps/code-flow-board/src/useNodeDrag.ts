import { useState, type Dispatch, type PointerEvent, type SetStateAction } from "react";
import type { BoardNode } from "./types";
import type { layoutFlow } from "./layout";

type LayoutState = Awaited<ReturnType<typeof layoutFlow>>;

export function useNodeDrag(
  scale: number,
  setLayout: Dispatch<SetStateAction<LayoutState | null>>,
  setSelected: Dispatch<SetStateAction<string>>,
) {
  const [dragNode, setDragNode] = useState<{ id: string; x: number; y: number } | null>(null);

  function startNodeDrag(event: PointerEvent<SVGGElement>, node: BoardNode) {
    event.stopPropagation();
    event.currentTarget.setPointerCapture(event.pointerId);
    setSelected(node.id);
    setDragNode({ id: node.id, x: event.clientX, y: event.clientY });
  }

  function moveNode(event: PointerEvent<SVGGElement>, node: BoardNode) {
    if (!dragNode || dragNode.id !== node.id) return;
    event.stopPropagation();
    const dx = (event.clientX - dragNode.x) / scale;
    const dy = (event.clientY - dragNode.y) / scale;
    setDragNode({ id: node.id, x: event.clientX, y: event.clientY });
    setLayout((current) => {
      if (!current) return current;
      return {
        ...current,
        nodes: current.nodes.map((item) => item.id === node.id ? { ...item, x: item.x + dx, y: item.y + dy } : item),
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
