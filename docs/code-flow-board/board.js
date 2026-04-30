const state = {
  role: "",
  query: "",
  selected: null,
  lang: localStorage.getItem("codeFlowLang") || "ko",
};

const data = window.CODE_FLOW_DATA || null;
const I18N = window.CODE_FLOW_I18N;
const summaries = window.CODE_FLOW_SUMMARIES;
const summary = document.querySelector("#summary");
const roleList = document.querySelector("#roleList");
const flowMeta = document.querySelector("#flowMeta");
const graph = document.querySelector("#flowGraph");
const details = document.querySelector("#details");
const searchInput = document.querySelector("#searchInput");
const clearFilter = document.querySelector("#clearFilter");
const languageSelect = document.querySelector("#languageSelect");

function t(key) {
  return I18N[state.lang][key] || I18N.en[key] || key;
}

function roleName(role) {
  return I18N[state.lang].roleNames[role] || role;
}

function el(name, attrs = {}) {
  const node = document.createElementNS("http://www.w3.org/2000/svg", name);
  Object.entries(attrs).forEach(([key, value]) => node.setAttribute(key, value));
  return node;
}

function htmlEl(name, className = "") {
  const node = document.createElement(name);
  if (className) node.className = className;
  return node;
}

function matchesQuery(component) {
  const query = state.query.trim().toLowerCase();
  if (!query) return true;
  const haystack = [component.name, component.primaryRole, ...(component.sampleFiles || [])]
    .join(" ")
    .toLowerCase();
  return haystack.includes(query);
}

function visibleComponents() {
  return data.components
    .filter((item) => !state.role || item.primaryRole === state.role)
    .filter(matchesQuery)
    .sort((a, b) => b.fileCount - a.fileCount || a.name.localeCompare(b.name))
    .slice(0, 28);
}

function renderChrome() {
  document.documentElement.lang = state.lang;
  document.querySelector("#searchLabel").textContent = t("search");
  document.querySelector("#languageLabel").textContent = t("language");
  document.querySelector("#rolesTitle").textContent = t("roles");
  document.querySelector("#flowTitle").textContent = t("flow");
  document.querySelector("#detailsTitle").textContent = t("details");
  document.querySelector("#legendProcess").textContent = t("process");
  document.querySelector("#legendDecision").textContent = t("decision");
  document.querySelector("#legendData").textContent = t("data");
  document.querySelector("#legendIo").textContent = t("io");
  document.querySelector("#legendDocument").textContent = t("document");
  clearFilter.textContent = t("clear");
  searchInput.placeholder = state.lang === "ko" ? "컴포넌트, 파일, 역할" : "component, file, role";
  languageSelect.value = state.lang;
}

function renderSummary() {
  const generated = new Date(data.generatedAt).toLocaleString();
  summary.replaceChildren(...[
    [t("filesScanned"), data.fileCount],
    [t("roles"), Object.keys(data.roles).length],
    [t("components"), data.components.length],
    [t("references"), data.dependencies.length + data.externalDependencies.length],
  ].map(([label, value]) => {
    const metric = htmlEl("article", "metric");
    const labelNode = htmlEl("span");
    const valueNode = htmlEl("strong");
    labelNode.textContent = label;
    valueNode.textContent = value;
    metric.append(labelNode, valueNode);
    return metric;
  }));
  flowMeta.textContent = `${t("generated")} ${generated}`;
}

function renderRoles() {
  roleList.replaceChildren(...Object.entries(data.roles).map(([role, count]) => {
    const button = htmlEl("button", `roleItem ${state.role === role ? "active" : ""}`);
    const label = htmlEl("span");
    const value = htmlEl("strong");
    button.type = "button";
    button.dataset.role = role;
    label.textContent = roleName(role);
    value.textContent = count;
    button.append(label, value);
    return button;
  }));
}

function flowShape(item, type) {
  if (type === "role") return "terminator";
  if (item.primaryRole === "security" || item.primaryRole === "verification") return "decision";
  if (item.primaryRole === "database") return "data";
  if (item.primaryRole === "docs") return "document";
  if (item.primaryRole === "ui") return "io";
  if (item.primaryRole === "orchestration") return "subprocess";
  return "process";
}

function appendShape(group, shape, x, y) {
  const common = { class: "nodeShape" };
  if (shape === "decision") {
    group.append(el("path", { ...common, d: `M ${x + 95} ${y} L ${x + 190} ${y + 29} L ${x + 95} ${y + 58} L ${x} ${y + 29} Z` }));
  } else if (shape === "data") {
    group.append(el("path", { ...common, d: `M ${x} ${y + 10} C ${x} ${y - 3}, ${x + 190} ${y - 3}, ${x + 190} ${y + 10} L ${x + 190} ${y + 48} C ${x + 190} ${y + 61}, ${x} ${y + 61}, ${x} ${y + 48} Z M ${x} ${y + 10} C ${x} ${y + 23}, ${x + 190} ${y + 23}, ${x + 190} ${y + 10}` }));
  } else if (shape === "io") {
    group.append(el("path", { ...common, d: `M ${x + 18} ${y} H ${x + 190} L ${x + 172} ${y + 58} H ${x} Z` }));
  } else if (shape === "document") {
    group.append(el("path", { ...common, d: `M ${x} ${y} H ${x + 190} V ${y + 48} C ${x + 142} ${y + 66}, ${x + 54} ${y + 38}, ${x} ${y + 56} Z` }));
  } else {
    group.append(el("rect", { ...common, x, y, width: 190, height: 58, rx: shape === "terminator" ? 24 : 8 }));
    if (shape === "subprocess") group.append(el("rect", { class: "nodeInset", x: x + 9, y: y + 8, width: 172, height: 42, rx: 4 }));
  }
}

function nodeGroup(item, x, y, type) {
  const shape = flowShape(item, type);
  const group = el("g", {
    class: `node ${type} ${shape} ${state.selected === item.name ? "selected" : ""}`,
    tabindex: "0",
    role: "button",
    "data-name": item.name,
  });
  appendShape(group, shape, x, y);
  const name = el("text", { x: x + 14, y: y + 24 });
  const meta = el("text", { x: x + 14, y: y + 44 });
  name.textContent = item.name.length > 21 ? `${item.name.slice(0, 20)}...` : item.name;
  meta.textContent = `${roleName(item.primaryRole)} / ${item.fileCount} ${t("files")}`;
  group.append(name, meta);
  group.addEventListener("click", () => selectComponent(item.name));
  group.addEventListener("keydown", (event) => {
    if (event.key === "Enter" || event.key === " ") selectComponent(item.name);
  });
  return group;
}

function renderGraph() {
  const components = visibleComponents();
  const roles = [...new Set(components.map((item) => item.primaryRole))].sort();
  const roleNodes = roles.map((role) => ({ name: role, primaryRole: "role", fileCount: data.roles[role] }));
  const columns = Math.max(1, Math.min(4, Math.ceil(Math.sqrt(Math.max(components.length, 1)))));
  const width = Math.max(860, columns * 230 + 100, roleNodes.length * 220 + 80);
  const height = Math.max(620, 190 + Math.ceil(components.length / columns) * 95);
  graph.setAttribute("viewBox", `0 0 ${width} ${height}`);
  graph.replaceChildren();

  const rolePositions = new Map();
  roleNodes.forEach((role, index) => {
    const x = 40 + index * 220;
    rolePositions.set(role.name, { x, y: 35 });
    graph.append(nodeGroup(role, x, 35, "role"));
  });

  const componentPositions = new Map();
  components.forEach((component, index) => {
    const column = index % columns;
    const row = Math.floor(index / columns);
    componentPositions.set(component.name, { x: 60 + column * 230, y: 165 + row * 95 });
  });

  components.forEach((component) => {
    const from = rolePositions.get(component.primaryRole);
    const to = componentPositions.get(component.name);
    if (!from || !to) return;
    graph.append(el("path", {
      class: "edge",
      d: `M ${from.x + 95} ${from.y + 58} C ${from.x + 95} ${from.y + 115}, ${to.x + 95} ${to.y - 55}, ${to.x + 95} ${to.y}`,
    }));
  });

  components.forEach((component) => {
    const pos = componentPositions.get(component.name);
    graph.append(nodeGroup(component, pos.x, pos.y, "component"));
  });
  flowMeta.textContent = state.lang === "ko" ? `${components.length}${t("visible")}` : `${components.length} ${t("visible")}`;
}

function renderDetails() {
  const component = data.components.find((item) => item.name === state.selected) || visibleComponents()[0];
  if (!component) {
    const empty = htmlEl("p");
    empty.textContent = t("noMatch");
    details.replaceChildren(empty);
    return;
  }
  state.selected = component.name;
  const inbound = data.dependencies.filter((dep) => dep.to === component.name).length;
  const outbound = data.dependencies.filter((dep) => dep.from === component.name).length;
  const title = htmlEl("h3");
  const info = [htmlEl("p"), htmlEl("p"), htmlEl("p"), htmlEl("p")];
  const fileTitle = htmlEl("h4");
  const list = htmlEl("ul");
  title.textContent = component.name;
  info[0].textContent = `${t("summary")}: ${summaries.role(component.primaryRole, state.lang)}`;
  info[1].textContent = `${t("role")}: ${roleName(component.primaryRole)}`;
  info[2].textContent = `${t("files")}: ${component.fileCount}`;
  info[3].textContent = `${t("localRefs")}: ${outbound} ${t("outgoing")} / ${inbound} ${t("incoming")}`;
  fileTitle.textContent = t("fileSummary");
  (component.sampleFiles || []).forEach((file) => {
    const item = htmlEl("li");
    item.textContent = `${file} - ${summaries.file(file, state.lang)}`;
    list.append(item);
  });
  details.replaceChildren(title, ...info, fileTitle, list);
}

function selectComponent(name) {
  state.selected = name;
  renderGraph();
  renderDetails();
}

function render() {
  if (!data) {
    const shell = htmlEl("main", "shell");
    const title = htmlEl("h1");
    const message = htmlEl("p");
    title.textContent = "Code Flow Board";
    message.textContent = t("runFirst");
    shell.append(title, message);
    document.body.replaceChildren(shell);
    return;
  }
  renderChrome();
  renderSummary();
  renderRoles();
  renderGraph();
  renderDetails();
}

roleList.addEventListener("click", (event) => {
  const button = event.target.closest("[data-role]");
  if (!button) return;
  state.role = button.dataset.role;
  state.selected = null;
  render();
});

searchInput.addEventListener("input", (event) => {
  state.query = event.target.value;
  state.selected = null;
  render();
});

clearFilter.addEventListener("click", () => {
  state.role = "";
  state.query = "";
  state.selected = null;
  searchInput.value = "";
  render();
});

languageSelect.addEventListener("change", (event) => {
  state.lang = event.target.value;
  localStorage.setItem("codeFlowLang", state.lang);
  render();
});

render();
