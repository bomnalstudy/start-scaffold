import ELK from "elkjs/lib/elk.bundled.js";
import type { BoardEdge, BoardNode, CodeFlowData, Role } from "./types";

const elk = new ELK();
const nodeWidth = 230;
const nodeHeight = 78;
const supportingRoles = new Set<Role>(["docs", "skill"]);

function kindFor(role: string): BoardNode["kind"] {
  if (role === "security" || role === "verification") return "decision";
  if (role === "database" || role === "repository") return "data";
  if (role === "docs" || role === "skill") return "document";
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

function roleNode(role: Role, fileCount: number, sampleFiles: string[]): BoardNode {
  return {
    id: `role:${role}`,
    label: role,
    role,
    kind: kindFor(role),
    fileCount,
    sampleFiles,
    x: 0,
    y: 0,
    width: nodeWidth,
    height: nodeHeight,
  };
}

function filesByRole(data: CodeFlowData) {
  const groups = new Map<Role, string[]>();
  data.files.forEach((file) => {
    const list = groups.get(file.role) ?? [];
    if (list.length < 8) list.push(file.path);
    groups.set(file.role, list);
  });
  return groups;
}

function roleEdges(data: CodeFlowData) {
  const componentRoles = new Map(data.components.map((item) => [item.name, item.primaryRole]));
  const counts = new Map<string, number>();
  data.dependencies.forEach((edge) => {
    const from = componentRoles.get(edge.from);
    const to = componentRoles.get(edge.to);
    if (!from || !to || from === to) return;
    if (supportingRoles.has(from) || supportingRoles.has(to)) return;
    const key = `${from}->${to}`;
    counts.set(key, (counts.get(key) ?? 0) + edge.count);
  });
  return [...counts.entries()].map(([key, count], index) => {
    const [from, to] = key.split("->");
    return {
      id: `role-dep-${index}`,
      sources: [`role:${from}`],
      targets: [`role:${to}`],
      count,
    };
  });
}

export async function layoutFlow(data: CodeFlowData, query: string, role: string) {
  const normalizedQuery = query.trim().toLowerCase();
  const groupedFiles = filesByRole(data);
  const roles = (Object.keys(data.roles) as Role[])
    .filter((item) => !supportingRoles.has(item))
    .filter((item) => !role || item === role)
    .filter((item) => {
      if (!normalizedQuery) return true;
      const samples = groupedFiles.get(item) ?? [];
      return [item, ...samples].join(" ").toLowerCase().includes(normalizedQuery);
    })
    .sort((a, b) => data.roles[b] - data.roles[a] || a.localeCompare(b));

  const startNode = boundaryNode("__start", "Start", "start");
  const endNode = boundaryNode("__end", "End", "end");
  const roleNodes = roles.map((item) => roleNode(item, data.roles[item] ?? 0, groupedFiles.get(item) ?? []));
  const visibleRoleIds = new Set(roleNodes.map((item) => item.id));
  const internalEdges = roleEdges(data).filter((edge) => visibleRoleIds.has(edge.sources[0]) && visibleRoleIds.has(edge.targets[0]));
  const outgoing = new Set(internalEdges.map((edge) => edge.sources[0]));

  const nodes = [
    { id: startNode.id, width: nodeWidth, height: nodeHeight },
    ...roleNodes.map((item) => ({ id: item.id, width: nodeWidth, height: nodeHeight })),
    { id: endNode.id, width: nodeWidth, height: nodeHeight },
  ];
  const startEdges = roleNodes.map((item, index) => ({ id: `start-${index}`, sources: [startNode.id], targets: [item.id] }));
  const endEdges = roleNodes
    .filter((item) => !outgoing.has(item.id))
    .map((item, index) => ({ id: `end-${index}`, sources: [item.id], targets: [endNode.id] }));
  const edges = [...startEdges, ...internalEdges, ...endEdges];

  const graph = await elk.layout({
    id: "root",
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": "DOWN",
      "elk.spacing.nodeNode": "70",
      "elk.layered.spacing.nodeNodeBetweenLayers": "95",
      "elk.edgeRouting": "ORTHOGONAL",
    },
    children: nodes,
    edges,
  });

  const nodeMap = new Map<string, BoardNode>();
  nodeMap.set(startNode.id, startNode);
  nodeMap.set(endNode.id, endNode);
  roleNodes.forEach((item) => nodeMap.set(item.id, item));
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
