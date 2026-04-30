import ELK from "elkjs/lib/elk.bundled.js";
import type { BoardEdge, BoardNode, CodeFlowData, FlowComponent, Role } from "./types";

const elk = new ELK();
const nodeWidth = 210;
const nodeHeight = 64;

function kindFor(role: string): BoardNode["kind"] {
  if (role === "security" || role === "verification") return "decision";
  if (role === "database" || role === "repository") return "data";
  if (role === "docs") return "document";
  if (role === "ui") return "io";
  if (role === "orchestration" || role === "service") return "subprocess";
  if (role === "entrypoint") return "start";
  return "process";
}

function boundaryNode(id: "__start" | "__end", label: string, kind: "start" | "end"): BoardNode {
  return {
    id,
    label,
    role: "project",
    kind,
    fileCount: 0,
    sampleFiles: [],
    x: 0,
    y: 0,
    width: nodeWidth,
    height: nodeHeight,
  };
}

function roleNode(role: Role, fileCount: number): BoardNode {
  return {
    id: `role:${role}`,
    label: role,
    role,
    kind: "process",
    fileCount,
    sampleFiles: [],
    x: 0,
    y: 0,
    width: nodeWidth,
    height: nodeHeight,
  };
}

function nodeFromComponent(component: FlowComponent): BoardNode {
  return {
    id: component.name,
    label: component.name,
    role: component.primaryRole,
    kind: kindFor(component.primaryRole),
    fileCount: component.fileCount,
    sampleFiles: component.sampleFiles,
    description: component.description,
    x: 0,
    y: 0,
    width: nodeWidth,
    height: nodeHeight,
  };
}

function componentRank(component: FlowComponent, edgeCounts: Map<string, number>) {
  const connected = edgeCounts.get(component.name) ?? 0;
  const isAppCode = component.name.startsWith("apps/") ? 1 : 0;
  const isDocs = component.primaryRole === "docs" ? -1 : 0;
  return connected * 1000 + isAppCode * 500 + isDocs * 300 + component.fileCount;
}

export async function layoutFlow(data: CodeFlowData, query: string, role: string) {
  const normalizedQuery = query.trim().toLowerCase();
  const edgeCounts = new Map<string, number>();
  data.dependencies.forEach((edge) => {
    edgeCounts.set(edge.from, (edgeCounts.get(edge.from) ?? 0) + edge.count);
    edgeCounts.set(edge.to, (edgeCounts.get(edge.to) ?? 0) + edge.count);
  });

  const components = data.components
    .filter((item) => !role || item.primaryRole === role)
    .filter((item) => {
      if (!normalizedQuery) return true;
      return [item.name, item.primaryRole, ...item.sampleFiles].join(" ").toLowerCase().includes(normalizedQuery);
    })
    .sort((a, b) => componentRank(b, edgeCounts) - componentRank(a, edgeCounts) || a.name.localeCompare(b.name))
    .slice(0, 36);

  const startNode = boundaryNode("__start", "Start", "start");
  const endNode = boundaryNode("__end", "End", "end");
  const visibleRoles = [...new Set(components.map((item) => item.primaryRole))].sort();
  const roleNodes = visibleRoles.map((item) => roleNode(item, data.roles[item] ?? 0));
  const componentNames = new Set(components.map((item) => item.name));
  const visibleDeps = data.dependencies.filter((edge) => componentNames.has(edge.from) && componentNames.has(edge.to));
  const outgoing = new Set(visibleDeps.map((edge) => edge.from));

  const nodes = [
    { id: startNode.id, width: nodeWidth, height: nodeHeight },
    ...roleNodes.map((item) => ({ id: item.id, width: nodeWidth, height: nodeHeight })),
    ...components.map((item) => ({ id: item.name, width: nodeWidth, height: nodeHeight })),
    { id: endNode.id, width: nodeWidth, height: nodeHeight },
  ];
  const startEdges = roleNodes.map((item, index) => ({ id: `start-${index}`, sources: [startNode.id], targets: [item.id] }));
  const roleEdges = components.map((item, index) => ({
    id: `role-${index}`,
    sources: [`role:${item.primaryRole}`],
    targets: [item.name],
  }));
  const dependencyEdges = visibleDeps.map((edge, index) => ({ id: `dep-${index}`, sources: [edge.from], targets: [edge.to] }));
  const endEdges = components
    .filter((item) => !outgoing.has(item.name))
    .map((item, index) => ({ id: `end-${index}`, sources: [item.name], targets: [endNode.id] }));
  const edges = [...startEdges, ...roleEdges, ...dependencyEdges, ...endEdges];

  const graph = await elk.layout({
    id: "root",
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": "DOWN",
      "elk.spacing.nodeNode": "55",
      "elk.layered.spacing.nodeNodeBetweenLayers": "80",
      "elk.edgeRouting": "ORTHOGONAL",
    },
    children: nodes,
    edges,
  });

  const nodeMap = new Map<string, BoardNode>();
  nodeMap.set(startNode.id, startNode);
  nodeMap.set(endNode.id, endNode);
  roleNodes.forEach((item) => nodeMap.set(item.id, item));
  components.forEach((item) => nodeMap.set(item.name, nodeFromComponent(item)));
  graph.children?.forEach((item) => {
    const node = nodeMap.get(item.id);
    if (!node) return;
    node.x = item.x ?? 0;
    node.y = item.y ?? 0;
  });

  const boardEdges: BoardEdge[] = (graph.edges ?? []).map((edge) => ({
    id: edge.id,
    from: edge.sources[0],
    to: edge.targets[0],
    role: nodeMap.get(edge.targets[0])?.role ?? "project",
    points: edge.sections?.[0]?.bendPoints ?? [],
  }));
  return { nodes: [...nodeMap.values()], edges: boardEdges };
}
