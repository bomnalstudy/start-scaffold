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
  terms?: string[];
  confidence?: string;
  analysisSource?: "local-ai";
};

export type FlowEdge = {
  from: string;
  to: string;
  count: number;
};

export type InferredFlowNode = {
  id: string;
  type: "start" | "end" | "process" | "decision" | "data" | "io" | "document" | "subprocess";
  label: string;
  role: Role | "project";
  summary?: string;
  responsibilities?: string[];
  terms?: string[];
  files?: string[];
  evidence?: string[];
};

export type InferredFlowEdge = {
  from: string;
  to: string;
  label?: string;
  reason?: string;
};

export type InferredFlow = {
  id: string;
  name: string;
  summary: string;
  nodes: InferredFlowNode[];
  edges: InferredFlowEdge[];
};

export type FlowProgress = {
  status: "running" | "completed" | "failed" | string;
  language: string;
  completedBatches: number;
  totalBatches: number;
  planKey?: string;
  visibleMergeBatch?: number;
  updatedAt: string;
  message?: string;
  error?: string;
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
  flows?: InferredFlow[];
  flowSource?: "local-ai";
  flowGeneratedAt?: string;
  flowLanguage?: "ko" | "en" | string;
  flowComplete?: boolean;
  flowProgress?: FlowProgress;
};

export type BoardNode = {
  id: string;
  label: string;
  role: Role | "project";
  kind: "start" | "end" | "process" | "decision" | "data" | "io" | "document" | "subprocess";
  sequence?: {
    step?: string;
    total?: number;
    kind: "step" | "sequence";
  };
  fileCount: number;
  sampleFiles: string[];
  evidence?: string[];
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
