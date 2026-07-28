import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const root = path.resolve(__dirname, "..");
const build = path.join(root, "build");

console.log("Cleaning build folder...");

fs.rmSync(build, {
    recursive: true,
    force: true
});

fs.mkdirSync(build, {
    recursive: true
});

console.log("Copying source...");

fs.cpSync(
    path.join(root, "src"),
    path.join(build, "src"),
    { recursive: true }
);

fs.copyFileSync(
    path.join(root, "package.json"),
    path.join(build, "package.json")
);

fs.copyFileSync(
    path.join(root, "package-lock.json"),
    path.join(build, "package-lock.json")
);

console.log("Installing production dependencies...");

execSync("npm ci --omit=dev", {
    cwd: build,
    stdio: "inherit"
});

console.log("Creating lambda.zip...");

execSync(
    "npx bestzip lambda.zip *",
    {
        cwd: build,
        stdio: "inherit"
    }
);

console.log("Done!");