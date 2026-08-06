import { build } from "esbuild";
import fs from "node:fs";

const handlers = [
  "createPost",
  "getPosts",
  "getPostById",
  "updatePost",
  "deletePost"
];

// Clean dist folder
fs.rmSync("dist", { recursive: true, force: true });
fs.mkdirSync("dist", { recursive: true });

for (const handler of handlers) {
  console.log(`Building ${handler}...`);

  await build({
    entryPoints: [`src/handlers/${handler}.js`],
    bundle: true,
    platform: "node",
    target: "node24",
    format: "cjs",
    outfile: `dist/${handler}.js`,
    minify: true,
    treeShaking: true,
    external: ["@aws-sdk/*"]
  });
}

console.log("Build complete.");