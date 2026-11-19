// Quality rules the agent can't skip. Each message says what to write instead,
// so a lint error teaches the fix. Add a rule here before adding prose to CLAUDE.md.
import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig([
  { ignores: ["dist/", "build/", ".next/", "coverage/", ".claude/"] },
  js.configs.recommended,
  tseslint.configs.recommended,
  {
    rules: {
      // Replaced by the no-restricted-syntax entry below, which explains the fix.
      "@typescript-eslint/no-explicit-any": "off",
      "no-restricted-syntax": [
        "error",
        {
          selector: "TSAnyKeyword",
          message: "No `any`: use `unknown` and narrow it with a type guard, or write the real type.",
        },
        {
          selector: "CallExpression[callee.object.name='console'][callee.property.name=/^(log|debug)$/]",
          message: "No console.log/console.debug in committed code: delete the debug line, or use console.warn/console.error for real diagnostics.",
        },
      ],
      // @ts-ignore is banned; @ts-expect-error needs a reason and fails once the error is gone.
      "@typescript-eslint/ban-ts-comment": [
        "error",
        { "ts-ignore": true, "ts-expect-error": "allow-with-description", minimumDescriptionLength: 10 },
      ],
    },
  },
]);
