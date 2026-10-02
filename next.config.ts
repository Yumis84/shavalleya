import type { NextConfig } from "next";

const deploymentMode = process.env.PAGES_DEPLOYMENT_MODE || "github-pages";

const nextConfig: NextConfig = {
  output: deploymentMode !== "development" ? "export" : undefined,
  trailingSlash: true,
  basePath: deploymentMode === "custom-domain" ? "" : "/shavalleya",
  assetPrefix: deploymentMode === "custom-domain" ? undefined : "/shavalleya/",
  images: { unoptimized: true },
};

export default nextConfig;
