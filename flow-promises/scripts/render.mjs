// Renders a chart.mmd to SVG with Pele, colored by the CSS in statechart/references/render.md.
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import { createRequire } from "node:module";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const PELE = "pele@1.9.0";
const [mmdFile, svgFile] = process.argv.slice(2);
if (!mmdFile || !svgFile) {
  console.error("Usage: render.mjs CHART.mmd CHART.svg");
  process.exit(2);
}

const cache = process.env.XDG_CACHE_HOME ?? path.join(os.homedir(), ".cache");
const home = path.join(cache, "flow-promises", PELE);
const manifest = path.join(home, "package.json");
if (!fs.existsSync(path.join(home, "node_modules", "pele"))) {
  fs.mkdirSync(home, { recursive: true });
  if (!fs.existsSync(manifest)) fs.writeFileSync(manifest, "{}\n");
  execFileSync("npm", ["install", "--prefix", home, "--no-audit", "--no-fund", "--silent", PELE], {
    stdio: ["ignore", "ignore", "inherit"],
  });
}
const { render, PeleError } = await import(pathToFileURL(createRequire(manifest).resolve("pele")).href);

const guide = fs.readFileSync(new URL("../statechart/references/render.md", import.meta.url), "utf8");
const css = guide.match(/```css\n([\s\S]*?)```/)?.[1];
if (!css) {
  console.error("Cannot find the chart colors in statechart/references/render.md.");
  process.exit(2);
}

let svg;
try {
  ({ svg } = render(fs.readFileSync(mmdFile, "utf8"), {
    limit: 1_000_000,
    outputLimit: 8_000_000,
    maxEdges: 10_000,
  }));
} catch (error) {
  if (!(error instanceof PeleError)) throw error;
  console.error(`Pele cannot render ${mmdFile}: ${error.message}`);
  process.exit(2);
}
const open = svg.indexOf(">") + 1;
fs.writeFileSync(svgFile, `${svg.slice(0, open)}<style>\n${css}</style>${svg.slice(open)}`);
