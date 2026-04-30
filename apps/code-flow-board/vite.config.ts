import react from "@vitejs/plugin-react";
import { spawn } from "node:child_process";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, type ViteDevServer } from "vite";

const appDir = path.dirname(fileURLToPath(import.meta.url));
const scaffoldRoot = path.resolve(appDir, "../..");
const targetRoot = process.env.CODE_FLOW_ROOT ? path.resolve(process.env.CODE_FLOW_ROOT) : scaffoldRoot;
const serverPort = Number(process.env.CODE_FLOW_PORT ?? 5179);
const dataPath = path.join(targetRoot, "docs/generated/code-flow.json");
const memoryPath = path.join(targetRoot, "docs/generated/code-flow-memory.json");
const analyzerPath = path.join(scaffoldRoot, "scripts/shared/analyze_code_flow.py");
const flowInferPath = path.join(scaffoldRoot, "scripts/shared/infer_code_flows.py");
const aiCommand = process.env.CODE_FLOW_AI_COMMAND ?? "";
const flowLanguage = process.env.CODE_FLOW_LANGUAGE ?? process.env.CODE_FLOW_DESCRIPTION_LANG ?? "ko";
const flowMax = process.env.CODE_FLOW_MAX_COMPONENTS ?? process.env.CODE_FLOW_DESCRIPTION_MAX ?? "0";
const flowMaxFiles = process.env.CODE_FLOW_MAX_FILES_PER_COMPONENT ?? "4";
const flowBatchSize = process.env.CODE_FLOW_BATCH_SIZE ?? "4";
const ignoredParts = new Set([
  ".git",
  ".graveyard",
  ".tmp",
  "build",
  "dist",
  "docs/generated",
  "node_modules",
  "references",
  "start-scaffold",
]);

function shouldIgnore(filePath: string) {
  const relative = path.relative(targetRoot, filePath).replaceAll("\\", "/");
  if (relative.startsWith("..")) return true;
  return [...ignoredParts].some((part) => relative === part || relative.startsWith(`${part}/`));
}

function runAnalyzer() {
  return new Promise<void>((resolve, reject) => {
    const python = process.platform === "win32" ? "python" : "python3";
    const child = spawn(python, [analyzerPath, "--root", targetRoot], { stdio: "inherit" });
    child.on("error", reject);
    child.on("exit", (code) => code === 0 ? resolve() : reject(new Error(`Analyzer exited with ${code}`)));
  });
}

function runFlowInference() {
  if (!aiCommand) return Promise.reject(new Error("CODE_FLOW_AI_COMMAND is required for AI flow inference."));
  return new Promise<void>((resolve, reject) => {
    const python = process.platform === "win32" ? "python" : "python3";
    const args = [
      flowInferPath,
      "--root",
      targetRoot,
      "--language",
      flowLanguage,
      "--max-components",
      flowMax,
      "--max-files-per-component",
      flowMaxFiles,
      "--batch-size",
      flowBatchSize,
      "--ai-command",
      aiCommand,
    ];
    const child = spawn(python, args, { stdio: "inherit" });
    child.on("error", reject);
    child.on("exit", (code) => code === 0 ? resolve() : reject(new Error(`Flow inference exited with ${code}`)));
  });
}

async function refreshFlow() {
  await runAnalyzer();
  await runFlowInference();
}

async function readFlowData() {
  const content = await readFile(dataPath, "utf8");
  const parsed = JSON.parse(content) as { flows?: unknown[] };
  if (!parsed.flows?.length) {
    try {
      return await readFile(memoryPath, "utf8");
    } catch {
      return content;
    }
  }
  return content;
}

function flowBoardPlugin() {
  return {
    name: "flow-board-live-data",
    configureServer(server: ViteDevServer) {
      const clients = new Set<import("node:http").ServerResponse>();
      let timer: NodeJS.Timeout | undefined;

      server.watcher.add(targetRoot);
      server.middlewares.use("/api/code-flow", async (_req, res) => {
        try {
          res.setHeader("Content-Type", "application/json; charset=utf-8");
          res.end(await readFlowData());
        } catch {
          await refreshFlow();
          res.end(await readFile(dataPath, "utf8"));
        }
      });

      server.middlewares.use("/api/events", (_req, res) => {
        res.writeHead(200, {
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          Connection: "keep-alive",
        });
        clients.add(res);
        res.write("event: ready\ndata: {}\n\n");
        res.on("close", () => clients.delete(res));
      });

      server.watcher.on("change", (filePath) => {
        if (shouldIgnore(filePath)) return;
        clearTimeout(timer);
        timer = setTimeout(async () => {
          try {
            await refreshFlow();
            clients.forEach((client) => client.write(`event: flow-update\ndata: ${Date.now()}\n\n`));
          } catch (error) {
            console.error(error);
          }
        }, 500);
      });
    },
  };
}

export default defineConfig({
  root: appDir,
  plugins: [react(), flowBoardPlugin()],
  server: {
    host: "127.0.0.1",
    port: serverPort,
  },
  build: {
    outDir: path.join(scaffoldRoot, "dist/code-flow-board"),
    emptyOutDir: true,
  },
});
