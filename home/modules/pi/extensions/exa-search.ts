import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

interface ExaResult {
	title: string;
	url: string;
	text?: string;
	highlights?: string[];
	publishedDate?: string | null;
	author?: string | null;
}

interface ExaResponse {
	results: ExaResult[];
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "exa_search",
		label: "Exa Search",
		description:
			"Search the web via Exa. Returns title, URL, and key highlight snippets for each result. Use for current events, recent documentation, fact-checking, or anything that requires up-to-date web information.",
		promptSnippet: "Search the web via Exa for current information",
		promptGuidelines: [
			"Use exa_search when the user asks about recent events, current documentation, or anything requiring up-to-date web information that may not be in your training data.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
			numResults: Type.Optional(
				Type.Number({ description: "Number of results to return (1-20)", default: 5 }),
			),
		}),
		async execute(_toolCallId, params, signal) {
			const apiKey = process.env.EXA_API_KEY;
			if (!apiKey) {
				throw new Error("EXA_API_KEY not set in environment");
			}

			const response = await fetch("https://api.exa.ai/search", {
				method: "POST",
				headers: {
					"x-api-key": apiKey,
					"content-type": "application/json",
				},
				body: JSON.stringify({
					query: params.query,
					numResults: params.numResults ?? 5,
					contents: { highlights: { maxCharacters: 1500 } },
				}),
				signal,
			});

			if (!response.ok) {
				const body = await response.text().catch(() => "");
				throw new Error(`Exa search failed: ${response.status} ${response.statusText}${body ? ` — ${body}` : ""}`);
			}

			const data = (await response.json()) as ExaResponse;

			const formatted = data.results
				.map((r, i) => {
					const snippet = (r.highlights ?? []).join(" … ");
					return `${i + 1}. ${r.title}\n   ${r.url}${snippet ? `\n   ${snippet}` : ""}`;
				})
				.join("\n\n");

			return {
				content: [{ type: "text", text: formatted || "No results" }],
				details: { results: data.results },
			};
		},
	});
}
