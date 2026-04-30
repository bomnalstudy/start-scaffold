export type Role =
  | "automation"
  | "backend"
  | "config"
  | "database"
  | "domain"
  | "docs"
  | "entrypoint"
  | "orchestration"
  | "repository"
  | "security"
  | "skill"
  | "service"
  | "ui"
  | "verification";

export type FlowComponent = {
  name: string;
  primaryRole: Role;
  fileCount: number;
  sampleFiles: string[];
  description?: FlowDescription;
};

export type FlowDescription = {
  summary: string;
  responsibilities: string[];
  relationships: string[];
  confidence?: string;
  analysisSource?: "local-ai";
};

export type FlowEdge = {
  from: string;
  to: string;
  count: number;
};

export type CodeFlowData = {
  generatedAt: string;
  root: string;
  fileCount: number;
  roles: Record<string, number>;
  components: FlowComponent[];
  dependencies: FlowEdge[];
  externalDependencies: FlowEdge[];
  files: Array<{ path: string; role: Role; component: string }>;
};

export type BoardNode = {
  id: string;
  label: string;
  role: Role | "project";
  kind: "start" | "end" | "process" | "decision" | "data" | "io" | "document" | "subprocess";
  fileCount: number;
  sampleFiles: string[];
  description?: FlowDescription;
  x: number;
  y: number;
  width: number;
  height: number;
};

export type BoardEdge = {
  id: string;
  from: string;
  to: string;
  label?: string;
  role: Role | "project";
  points: Array<{ x: number; y: number }>;
};
