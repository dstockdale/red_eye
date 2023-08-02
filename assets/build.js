const esbuild = require("esbuild");
const { solidPlugin } = require("esbuild-plugin-solid");
const sveltePlugin = require("esbuild-svelte");
const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = {
  ".js": "jsx",
};

const plugins = [solidPlugin(), sveltePlugin()];

let opts = {
  entryPoints: ["js/app.js"],
  mainFields: ["svelte", "browser", "module", "main"],
  bundle: true,
  logLevel: "info",
  target: "es2017",
  outdir: "../priv/static/assets",
  external: ["*.css", "fonts/*", "images/*"],
  loader: loader,
  plugins: plugins,
};

if (deploy) {
  opts = {
    ...opts,
    minify: true,
  };
}

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };
  esbuild
    .context(opts)
    .then((ctx) => {
      ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  esbuild.build(opts);
}
