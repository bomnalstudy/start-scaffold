import { useEffect, useMemo, useState } from "react";
import { createTranslator, type Language, roleSummary } from "./i18n";
import { layoutFlow } from "./layout";
import type { BoardEdge, BoardNode, Role } from "./types";
import { useCanvasView } from "./useCanvasView";
import { useCodeFlow } from "./useCodeFlow";
import { useNodeDrag } from "./useNodeDrag";

type LayoutState = Awaited<ReturnType<typeof layoutFlow>>;
const supportingRoles = new Set<Role>(["docs", "skill"]);

const roleIcons: Record<Role | "project", string> = {
  automation: "AU", backend: "BE", config: "CF", database: "DB", domain: "DO",
  docs: "DO", entrypoint: "ST", orchestration: "OR", repository: "RP",
  security: "SE", skill: "SK", service: "SV", ui: "UI", verification: "VE",
  project: "PR",
};

function pathFor(edge: BoardEdge, nodes: BoardNode[]) {
  const from = nodes.find((node) => node.id === edge.from);
  const to = nodes.find((node) => node.id === edge.to);
  if (!from || !to) return "";
  const start = { x: from.x + from.width / 2, y: from.y + from.height };
  const end = { x: to.x + to.width / 2, y: to.y };
  const midY = start.y + Math.max(42, (end.y - start.y) / 2);
  return `M ${start.x} ${start.y} L ${start.x} ${midY} L ${end.x} ${midY} L ${end.x} ${end.y}`;
}

function shapePath(node: BoardNode) {
  const { x, y, width: w, height: h } = node;
  if (node.kind === "decision") return `M ${x + w / 2} ${y} L ${x + w} ${y + h / 2} L ${x + w / 2} ${y + h} L ${x} ${y + h / 2} Z`;
  if (node.kind === "data") return `M ${x} ${y + 12} C ${x} ${y - 4}, ${x + w} ${y - 4}, ${x + w} ${y + 12} L ${x + w} ${y + h - 12} C ${x + w} ${y + h + 4}, ${x} ${y + h + 4}, ${x} ${y + h - 12} Z M ${x} ${y + 12} C ${x} ${y + 28}, ${x + w} ${y + 28}, ${x + w} ${y + 12}`;
  if (node.kind === "io") return `M ${x + 22} ${y} H ${x + w} L ${x + w - 22} ${y + h} H ${x} Z`;
  if (node.kind === "document") return `M ${x} ${y} H ${x + w} V ${y + h - 14} C ${x + w * 0.72} ${y + h + 8}, ${x + w * 0.25} ${y + h - 24}, ${x} ${y + h} Z`;
  return "";
}

function App() {
  const [layout, setLayout] = useState<LayoutState | null>(null);
  const [layoutError, setLayoutError] = useState("");
  const [language, setLanguage] = useState<Language>(() => (localStorage.getItem("codeFlowLang") as Language) || "ko");
  const [query, setQuery] = useState("");
  const [role, setRole] = useState("");
  const [selected, setSelected] = useState("project");
  const { t, role: roleLabel } = useMemo(() => createTranslator(language), [language]);
  const { data, error } = useCodeFlow(t("error"));
  const canvas = useCanvasView();
  const nodeDrag = useNodeDrag(canvas.view.scale, setLayout, setSelected);

  useEffect(() => {
    if (!data) return;
    layoutFlow(data, query, role).then((nextLayout) => {
      setLayout(nextLayout);
      setLayoutError("");
    }).catch(() => setLayoutError(t("error")));
  }, [data, query, role, t]);

  useEffect(() => {
    localStorage.setItem("codeFlowLang", language);
    document.documentElement.lang = language;
  }, [language]);

  const selectedNode = layout?.nodes.find((node) => node.id === selected) ?? layout?.nodes[0];
  const inbound = layout?.edges.filter((edge) => edge.to === selectedNode?.id).length ?? 0;
  const outbound = layout?.edges.filter((edge) => edge.from === selectedNode?.id).length ?? 0;
  const refCount = (nodeId: string) => {
    if (!layout) return 0;
    return layout.edges.filter((edge) => edge.to === nodeId || edge.from === nodeId).length;
  };
  const nodeTitle = (node: BoardNode) => node.id.startsWith("role:") ? roleLabel(node.role as Role) : node.label;
  const refLevel = Math.min(5, Math.max(1, Math.ceil((inbound + outbound) / 3)));
  const summary = selectedNode?.description?.summary ?? roleSummary(selectedNode?.role ?? "domain", language);
  const sourceLabel = selectedNode?.description?.analysisSource === "local-ai" ? "Local AI" : "";
  const maxX = layout ? Math.max(...layout.nodes.map((node) => node.x + node.width)) + 140 : 900;
  const maxY = layout ? Math.max(...layout.nodes.map((node) => node.y + node.height)) + 140 : 620;

  return (
    <main className="mapShell">
      <aside className="leftRail">
        <div className="railTop">
          <button type="button">{t("workspace")}</button>
          <button type="button">x</button>
        </div>
        <label className="searchBox">
          <span>{t("search")}</span>
          <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder={t("searchPlaceholder")} />
        </label>
        <section className="railSection">
          <h2>{t("favorites")}</h2>
          <button className={!role ? "active" : ""} type="button" onClick={() => setRole("")}>* {t("pureChaos")}</button>
        </section>
        <section className="railSection">
          <h2>{t("roles")}</h2>
          {data && Object.entries(data.roles).filter(([item]) => !supportingRoles.has(item as Role)).map(([item, count]) => (
            <button className={role === item ? "active" : ""} key={item} type="button" onClick={() => setRole(item)}>
              <span>{roleLabel(item as Role)}</span><strong>{count}</strong>
            </button>
          ))}
        </section>
      </aside>

      <section className="mapArea">
        <header className="floatingTop">
          <div className="crumb"><span className="appDot">CF</span><strong>{t("title")}</strong></div>
          <div className="topActions">
            <span>{t("live")}</span>
            <select value={language} onChange={(event) => setLanguage(event.target.value as Language)}>
              <option value="ko">Korean</option>
              <option value="en">English</option>
            </select>
          </div>
        </header>

        <div
          className={`canvas ${canvas.spaceDown ? "isPannable" : ""}`}
          {...canvas.handlers}
        >
          {(error || layoutError) && <p className="error">{error || layoutError}</p>}
          <div className="canvasContent" style={canvas.canvasVars}>
            <svg viewBox={`0 0 ${maxX} ${maxY}`} role="img" aria-label="Code flow graph">
              <defs>
                <marker id="arrow" markerHeight="8" markerWidth="8" orient="auto" refX="7" refY="4">
                  <path d="M 0 0 L 8 4 L 0 8 z" />
                </marker>
              </defs>
              {layout?.edges.map((edge) => <path className={`edge edge-${edge.role}`} d={pathFor(edge, layout.nodes)} key={edge.id} markerEnd="url(#arrow)" />)}
              {layout?.nodes.map((node) => (
                <g
                  className={`node node-${node.role} ${selectedNode?.id === node.id ? "selected" : ""} ${nodeDrag.draggingId === node.id ? "dragging" : ""}`}
                  key={node.id}
                  onClick={() => setSelected(node.id)}
                  onPointerDown={(event) => nodeDrag.startNodeDrag(event, node)}
                  onPointerMove={(event) => nodeDrag.moveNode(event, node)}
                  onPointerUp={nodeDrag.stopNodeDrag}
                >
                  {shapePath(node)
                    ? <path className="nodeShape" d={shapePath({ ...node, height: node.height + 18 })} />
                    : <rect className="nodeShape" x={node.x} y={node.y} width={node.width} height={node.height + 18} rx={node.kind === "start" ? 24 : 10} />}
                  {node.kind === "subprocess" && <rect className="nodeInset" x={node.x + 10} y={node.y + 9} width={node.width - 20} height={node.height} rx="5" />}
                  <circle className="nodeIcon" cx={node.x + 22} cy={node.y + 22} r="12" />
                  <text className="nodeIconText" x={node.x + 22} y={node.y + 26}>{roleIcons[node.role]}</text>
                  <text className="nodeTitle" x={node.x + 42} y={node.y + 23}>{nodeTitle(node).slice(0, 24)}</text>
                  <text className="nodeMeta" x={node.x + 42} y={node.y + 43}>{roleLabel(node.role)} / {node.fileCount} {t("files")}</text>
                  <text className="nodeBadge" x={node.x + 16} y={node.y + 70}>{node.sampleFiles[0]?.slice(0, 33) ?? `${t("references")}: ${refCount(node.id)}`}</text>
                </g>
              ))}
            </svg>
          </div>
        </div>

        <div className="zoomStack">
          <button type="button">{Math.round(canvas.view.scale * 100)}%</button>
          <button type="button" onClick={() => canvas.zoom(0.1)}>+</button>
          <button type="button" onClick={() => canvas.zoom(-0.1)}>-</button>
          <button type="button" onClick={canvas.reset}>F</button>
        </div>
        <button className="addButton" type="button">+</button>
      </section>

      <aside className="detailsDock">
        <div className="detailsHeader">
          <h2>{t("details")}</h2>
          <p>{data ? `${t("generated")} ${new Date(data.generatedAt).toLocaleString()}` : t("loading")}</p>
        </div>
        {selectedNode && (
          <div className="details">
            <h3>{nodeTitle(selectedNode)}</h3>
            {sourceLabel && <p>{sourceLabel} / confidence: {selectedNode.description?.confidence ?? "unknown"}</p>}
            <p>{t("summary")}: {summary}</p>
            {selectedNode.description?.responsibilities.length ? (
              <>
                <h4>{language === "ko" ? "하는 일" : "Responsibilities"}</h4>
                <ul>{selectedNode.description.responsibilities.map((item) => <li key={item}>{item}</li>)}</ul>
              </>
            ) : null}
            <section className="insightCard">
              <h4>{t("localRefs")}</h4>
              <div className={`progress level${refLevel}`}><span /></div>
              <p>{outbound} {t("outgoing")} / {inbound} {t("incoming")}</p>
            </section>
            {selectedNode.description?.relationships.length ? (
              <>
                <h4>{language === "ko" ? "관계 설명" : "Relationships"}</h4>
                <ul>{selectedNode.description.relationships.map((item) => <li key={item}>{item}</li>)}</ul>
              </>
            ) : null}
            <div className="stats">
              <article><span>{t("filesScanned")}</span><strong>{data?.fileCount ?? "-"}</strong></article>
              <article><span>{t("components")}</span><strong>{data?.components.length ?? "-"}</strong></article>
            </div>
            <h4>{t("files")}</h4>
            <ul>{selectedNode.sampleFiles.map((file) => <li key={file}>{file}</li>)}</ul>
          </div>
        )}
      </aside>
    </main>
  );
}

export default App;
