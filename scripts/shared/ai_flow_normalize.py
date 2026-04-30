FLOW_NODE_TYPES = {"start", "end", "process", "decision", "data", "io", "document", "subprocess"}


def clean_id(value: str, fallback: str) -> str:
    cleaned = "".join(char.lower() if char.isalnum() else "-" for char in value).strip("-")
    while "--" in cleaned:
        cleaned = cleaned.replace("--", "-")
    return cleaned or fallback


def normalize_flow(raw: dict) -> list[dict]:
    flows = raw.get("flows")
    if not isinstance(flows, list) or not flows:
        raise RuntimeError("AI JSON is missing flows.")
    normalized = []
    for flow_index, item in enumerate(flows[:3]):
        nodes = normalize_nodes(item)
        edges = normalize_edges(item, {node["id"] for node in nodes})
        if nodes:
            normalized.append(
                {
                    "id": clean_id(str(item.get("id", "")), f"flow-{flow_index}"),
                    "name": str(item.get("name") or f"Flow {flow_index + 1}").strip()[:80],
                    "summary": str(item.get("summary", "")).strip()[:500],
                    "nodes": nodes,
                    "edges": edges,
                }
            )
    return normalized


def normalize_nodes(item: dict) -> list[dict]:
    nodes = []
    seen = set()
    for node_index, node in enumerate(item.get("nodes", [])[:20]):
        node_id = clean_id(str(node.get("id") or node.get("label") or ""), f"node-{node_index}")
        if node_id in seen:
            node_id = f"{node_id}-{node_index}"
        seen.add(node_id)
        node_type = str(node.get("type", "process")).strip()
        if node_type not in FLOW_NODE_TYPES:
            node_type = "process"
        nodes.append(
            {
                "id": node_id,
                "type": node_type,
                "label": str(node.get("label") or node_id).strip()[:80],
                "role": str(node.get("role", "project")).strip(),
                "summary": str(node.get("summary", "")).strip()[:500],
                "responsibilities": [str(text).strip()[:220] for text in node.get("responsibilities", [])[:5] if str(text).strip()],
                "terms": [str(text).strip()[:220] for text in node.get("terms", [])[:6] if str(text).strip()],
                "files": [str(path).strip() for path in node.get("files", [])[:8] if str(path).strip()],
                "evidence": [str(text).strip()[:240] for text in node.get("evidence", [])[:5] if str(text).strip()],
            }
        )
    return nodes


def normalize_edges(item: dict, node_ids: set[str]) -> list[dict]:
    edges = []
    for edge in item.get("edges", [])[:28]:
        source = clean_id(str(edge.get("from", "")), "")
        target = clean_id(str(edge.get("to", "")), "")
        if source in node_ids and target in node_ids:
            edges.append(
                {
                    "from": source,
                    "to": target,
                    "label": str(edge.get("label", "")).strip()[:80],
                    "reason": str(edge.get("reason", "")).strip()[:260],
                }
            )
    return edges
