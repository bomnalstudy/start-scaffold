import { useCallback, useEffect, useRef, useState } from "react";
import type { Language } from "./i18n";
import type { CodeFlowData } from "./types";

export function useCodeFlow(errorMessage: string, language: Language) {
  const [data, setData] = useState<CodeFlowData | null>(null);
  const [error, setError] = useState("");
  const requestId = useRef(0);

  const loadFlow = useCallback(async () => {
    const currentRequest = requestId.current + 1;
    requestId.current = currentRequest;
    try {
      const params = new URLSearchParams({ t: String(Date.now()), lang: language });
      const response = await fetch(`/api/code-flow?${params.toString()}`);
      const nextData = await response.json() as CodeFlowData;
      if (currentRequest !== requestId.current) return;
      setData(nextData);
      setError("");
    } catch {
      if (currentRequest === requestId.current) setError(errorMessage);
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
