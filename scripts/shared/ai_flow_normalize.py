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


def graph_quality(flow: dict | None) -> int:
    if not flow:
        return -1
    flows = normalize_flow(flow)
    if not flows:
        return -1
    item = flows[0]
    nodes = item.get("nodes", [])
    edges = item.get("edges", [])
    node_ids = {node["id"] for node in nodes}
    out_degree = {node_id: 0 for node_id in node_ids}
    in_degree = {node_id: 0 for node_id in node_ids}
    for edge in edges:
        if edge["from"] in out_degree:
            out_degree[edge["from"]] += 1
        if edge["to"] in in_degree:
            in_degree[edge["to"]] += 1
    branch_count = sum(1 for value in out_degree.values() if value > 1)
    join_count = sum(1 for value in in_degree.values() if value > 1)
    start_count = sum(1 for node in nodes if node.get("type") == "start")
    end_count = sum(1 for node in nodes if node.get("type") == "end")
    linear_penalty = max(0, len(nodes) - branch_count - join_count - 6)
    return len(nodes) * 3 + len(edges) * 2 + branch_count * 8 + join_count * 4 + start_count + end_count - linear_penalty


def choose_better_flow(current: dict | None, candidate: dict) -> dict:
    if not current:
        return candidate
    current_score = graph_quality(current)
    candidate_score = graph_quality(candidate)
    return candidate if candidate_score >= current_score else current


def apply_flow_patch(current: dict | None, patch: dict) -> dict:
    if not current:
        return patch_to_flow(patch)
    flows = normalize_flow(current)
    if not flows:
        return patch_to_flow(patch)
    flow = flows[0]
    node_ids = {node["id"] for node in flow["nodes"]}
    edge_keys = {(edge["from"], edge["to"], edge.get("label", "")) for edge in flow["edges"]}
    for node in patch.get("addNodes", [])[:8]:
        normalized_node = normalize_nodes({"nodes": [node]})
        if normalized_node and normalized_node[0]["id"] not in node_ids:
            flow["nodes"].append(normalized_node[0])
            node_ids.add(normalized_node[0]["id"])
    for edge in patch.get("addEdges", [])[:12]:
        normalized = normalize_edges({"edges": [edge]}, node_ids)
        if normalized:
            item = normalized[0]
            key = (item["from"], item["to"], item.get("label", ""))
            if key not in edge_keys:
                flow["edges"].append(item)
                edge_keys.add(key)
    return {"flows": [flow]}


def patch_to_flow(patch: dict) -> dict:
    return {
        "flows": [
            {
                "id": "main",
                "name": str(patch.get("name") or "Code workflow")[:80],
                "summary": str(patch.get("summary") or "")[:500],
                "nodes": normalize_nodes({"nodes": patch.get("addNodes", [])}),
                "edges": [],
            }
        ]
    }




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
