import ELK from "elkjs/lib/elk.bundled.js";
import type { BoardEdge, BoardNode, CodeFlowData, InferredFlow, InferredFlowNode, Role } from "./types";

const elk = new ELK();
const nodeWidth = 250;
const nodeHeight = 88;
const nodeExtraHeight = 18;
const supportingRoles = new Set<Role>(["docs", "skill"]);

function fallbackFlow(data: CodeFlowData): InferredFlow {
  return {
    id: "ai-flow-required",
    name: "AI flow inference required",
    summary: "Start the board with a local AI command so the actual runtime workflow can be inferred from code.",
    nodes: [
      {
        id: "ai-flow-required",
        type: "process",
        role: "project",
        label: "AI flow inference required",
        summary: "The current data only has file groups. Run the local AI flow inference step to generate real start, decision, action, and end nodes.",
        files: data.components.slice(0, 6).flatMap((component) => component.sampleFiles.slice(0, 1)),
      },
    ],
    edges: [],
  };
}

function selectedFlow(data: CodeFlowData) {
  const flow = data.flows?.find((item) => item.nodes.length > 1) ?? data.flows?.[0];
  return flow ?? fallbackFlow(data);
}

function filesForNode(data: CodeFlowData, node: InferredFlowNode) {
  if (node.files?.length) return node.files.slice(0, 8);
  if (node.role === "project") return data.files.slice(0, 8).map((file) => file.path);
  return data.files.filter((file) => file.role === node.role).slice(0, 8).map((file) => file.path);
}

function fileCountForNode(data: CodeFlowData, node: InferredFlowNode, sampleFiles: string[]) {
  if (node.files?.length) return node.files.length;
  if (node.role === "project") return data.fileCount;
  return data.roles[node.role] ?? sampleFiles.length;
}

function toBoardNode(data: CodeFlowData, node: InferredFlowNode): BoardNode {
  const sampleFiles = filesForNode(data, node);
  return {
    id: node.id,
    label: node.label,
    role: node.role,
    kind: node.type,
    fileCount: fileCountForNode(data, node, sampleFiles),
    sampleFiles,
    evidence: node.evidence?.slice(0, 4),
    description: node.summary
      ? {
          summary: node.summary,
          responsibilities: node.responsibilities?.slice(0, 4) ?? [],
          relationships: [],
          terms: node.terms?.slice(0, 5) ?? [],
          confidence: data.flowSource === "local-ai" ? "medium" : "low",
          analysisSource: data.flowSource,
        }
      : undefined,
    x: 0,
    y: 0,
    width: nodeWidth,
    height: nodeHeight,
  };
}

function matchesNode(node: BoardNode, query: string, role: string) {
  if (role && node.role !== role && node.role !== "project") return false;
  if (!query) return true;
  return [node.label, node.role, node.description?.summary, ...node.sampleFiles, ...(node.evidence ?? [])]
    .join(" ")
    .toLowerCase()
    .includes(query);
}

function visibleEdge(edge: InferredFlow["edges"][number], nodeIds: Set<string>) {
  return nodeIds.has(edge.from) && nodeIds.has(edge.to);
}

export async function layoutFlow(data: CodeFlowData, query: string, role: string) {
  const normalizedQuery = query.trim().toLowerCase();
  const flow = selectedFlow(data);
  const boardNodes = flow.nodes
    .filter((node) => node.role === "project" || !supportingRoles.has(node.role))
    .map((node) => toBoardNode(data, node))
    .filter((node) => matchesNode(node, normalizedQuery, role));

  const nodeIds = new Set(boardNodes.map((node) => node.id));
  const flowEdges = flow.edges.filter((edge) => visibleEdge(edge, nodeIds));
  const graph = await elk.layout({
    id: "root",
    layoutOptions: {
      "elk.algorithm": "layered",
      "elk.direction": "DOWN",
      "elk.spacing.nodeNode": "150",
      "elk.spacing.edgeNode": "52",
      "elk.spacing.edgeEdge": "36",
      "elk.layered.spacing.nodeNodeBetweenLayers": "190",
      "elk.layered.spacing.edgeNodeBetweenLayers": "70",
      "elk.layered.spacing.edgeEdgeBetweenLayers": "44",
      "elk.edgeRouting": "ORTHOGONAL",
      "elk.layered.nodePlacement.strategy": "NETWORK_SIMPLEX",
    },
    children: boardNodes.map((node) => ({ id: node.id, width: node.width, height: node.height + nodeExtraHeight })),
    edges: flowEdges.map((edge, index) => ({
      id: `${edge.from}->${edge.to}:${index}`,
      sources: [edge.from],
      targets: [edge.to],
      labels: edge.label ? [{ text: edge.label }] : undefined,
    })),
  });

  const nodeMap = new Map(boardNodes.map((node) => [node.id, node]));
  graph.children?.forEach((item) => {
    const node = nodeMap.get(item.id);
    if (!node) return;
    node.x = item.x ?? 0;
    node.y = item.y ?? 0;
  });

  const boardEdges: BoardEdge[] = (graph.edges ?? []).map((edge, index) => {
    const original = flowEdges[index];
    return {
      id: edge.id,
      from: edge.sources[0],
      to: edge.targets[0],
      label: original?.label,
      role: nodeMap.get(edge.targets[0])?.role ?? "project",
      points: pointsForSection(edge.sections?.[0]),
    };
  });

  return { nodes: [...nodeMap.values()], edges: boardEdges, flow };
}

function pointsForSection(section: { startPoint?: { x: number; y: number }; bendPoints?: Array<{ x: number; y: number }>; endPoint?: { x: number; y: number } } | undefined) {
  if (!section?.startPoint || !section.endPoint) return [];
  return [section.startPoint, ...(section.bendPoints ?? []), section.endPoint];
}
