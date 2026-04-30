import { useEffect, useState } from "react";
import type { CodeFlowData } from "./types";

export function useCodeFlow(errorMessage: string) {
  const [data, setData] = useState<CodeFlowData | null>(null);
  const [error, setError] = useState("");

  async function loadFlow() {
    try {
      const response = await fetch(`/api/code-flow?t=${Date.now()}`);
      const nextData = await response.json() as CodeFlowData;
      setData(nextData);
      setError("");
    } catch {
      setError(errorMessage);
    }
  }

  useEffect(() => {
    loadFlow();
    const events = new EventSource("/api/events");
    events.addEventListener("flow-update", loadFlow);
    return () => events.close();
  }, [errorMessage]);

  return { data, error, reload: loadFlow };
}
