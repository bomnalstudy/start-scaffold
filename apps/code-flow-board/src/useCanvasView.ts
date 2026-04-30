import { useEffect, useState, type PointerEvent, type WheelEvent } from "react";

export type CanvasVars = React.CSSProperties & {
  "--pan-x": string;
  "--pan-y": string;
  "--zoom": number;
};

export function useCanvasView() {
  const [view, setView] = useState({ x: 0, y: 0, scale: 1 });
  const [spaceDown, setSpaceDown] = useState(false);
  const [dragStart, setDragStart] = useState<{ x: number; y: number; vx: number; vy: number } | null>(null);

  useEffect(() => {
    const keyDown = (event: KeyboardEvent) => {
      if (event.code === "Space" && event.target === document.body) {
        event.preventDefault();
        setSpaceDown(true);
      }
    };
    const keyUp = (event: KeyboardEvent) => {
      if (event.code === "Space") {
        setSpaceDown(false);
        setDragStart(null);
      }
    };
    window.addEventListener("keydown", keyDown);
    window.addEventListener("keyup", keyUp);
    return () => {
      window.removeEventListener("keydown", keyDown);
      window.removeEventListener("keyup", keyUp);
    };
  }, []);

  function zoom(delta: number) {
    setView((current) => ({ ...current, scale: Math.min(2.2, Math.max(0.35, current.scale + delta)) }));
  }

  function wheel(event: WheelEvent<HTMLDivElement>) {
    if (!event.altKey) return;
    event.preventDefault();
    zoom(event.deltaY > 0 ? -0.08 : 0.08);
  }

  function pointerDown(event: PointerEvent<HTMLDivElement>) {
    if (!spaceDown) return;
    event.currentTarget.setPointerCapture(event.pointerId);
    setDragStart({ x: event.clientX, y: event.clientY, vx: view.x, vy: view.y });
  }

  function pointerMove(event: PointerEvent<HTMLDivElement>) {
    if (!dragStart) return;
    setView((current) => ({
      ...current,
      x: dragStart.vx + event.clientX - dragStart.x,
      y: dragStart.vy + event.clientY - dragStart.y,
    }));
  }

  return {
    view,
    spaceDown,
    zoom,
    reset: () => setView({ x: 0, y: 0, scale: 1 }),
    canvasVars: { "--pan-x": `${view.x}px`, "--pan-y": `${view.y}px`, "--zoom": view.scale } as CanvasVars,
    handlers: {
      onPointerDown: pointerDown,
      onPointerMove: pointerMove,
      onPointerUp: () => setDragStart(null),
      onWheel: wheel,
    },
  };
}
