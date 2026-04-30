import { useCallback, useEffect, useState } from "react";
import type { Language } from "./i18n";
import type { CodeFlowData } from "./types";

export function useCodeFlow(errorMessage: string, language: Language) {
  const [data, setData] = useState<CodeFlowData | null>(null);
  const [error, setError] = useState("");

  const loadFlow = useCallback(async () => {
    try {
      const params = new URLSearchParams({ t: String(Date.now()), lang: language });
      const response = await fetch(`/api/code-flow?${params.toString()}`);
      const nextData = await response.json() as CodeFlowData;
      setData(nextData);
      setError("");
    } catch {
      setError(errorMessage);
    }
  }, [errorMessage, language]);

  useEffect(() => {
    loadFlow();
    const events = new EventSource("/api/events");
    events.addEventListener("flow-update", loadFlow);
    return () => events.close();
  }, [loadFlow]);

  return { data, error, reload: loadFlow };
}
