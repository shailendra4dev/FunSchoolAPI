import { execSync } from "node:child_process";

const handlers = [
  "createPost",
  "getPosts",
  "getPostById",
  "updatePost",
  "deletePost"
];

for (const handler of handlers) {
  execSync(
    `powershell Compress-Archive -Path dist/${handler}.js -DestinationPath dist/${handler}.zip -Force`,
    { stdio: "inherit" }
  );
}