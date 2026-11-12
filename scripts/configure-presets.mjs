import { cpSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const [templateArg, purgeArg] = process.argv.slice(2);
if (!templateArg || !purgeArg) throw new Error('Usage: configure-presets.mjs TEMPLATE PURGE_PACKAGE');
const template = resolve(templateArg);
const source = join(resolve(purgeArg), 'presets/unrestricted');
const base = readFileSync(join(source, 'agent.cordis.yml'), 'utf8');
const marker = '    includeDefaultRoots: true';
if (base.split(marker).length !== 2) throw new Error('Unexpected Purge preset layout');
const withSkills = dirs => base.replace(marker, `${marker}\n    customSkillDirs:\n${dirs.map(dir => `      - !!js dshHomePath('${dir}')`).join('\n')}`);
const rea = `\n- id: rea-mcp\n  name: '@deepseek-ai/dsh-mcp-client'\n  config:\n    serverName: rea\n    transport: stdio\n    command: !!js dshHomePath('tools/node/bin/node')\n    args:\n      - !!js dshHomePath('tools/rea/node_modules/rea-agents/scripts/rea.mjs')\n      - mcp\n    env:\n      REA_MCP_TOOL_FAMILIES: direct,enhanced,native,session\n      GHIDRA_INSTALL_DIR: !!js dshHomePath('tools/ghidra')\n      JAVA_HOME: !!js dshHomePath('tools/jdk/Contents/Home')\n    toolCallTimeoutMs: 180000\n`;
const craft = `\n- id: craft-mcp\n  name: '@deepseek-ai/dsh-mcp-client'\n  config:\n    serverName: craft\n    transport: stdio\n    command: !!js dshHomePath('tools/craft/craft-anything-cli')\n    args: [mcp, --deep]\n    toolCallTimeoutMs: 180000\n`;
const presets = [
  ['unrestricted', null, withSkills(['tools/rea/node_modules/rea-agents/skills']) + rea],
  ['portable-reverse', 'name: 逆向模式（REA + Reverse Skill）\ndescription: REA 与 Ghidra 负责分析，Reverse Skill 按需提供方法。\norder: 24\n', withSkills(['tools/rea/node_modules/rea-agents/skills', 'tools/reverse-skill/skills']) + rea],
  ['portable-craft', 'name: 无限制模式 + Craft Anything\ndescription: 使用 Craft Anything 研究和重建经授权的软件功能。\norder: 25\n', base + craft],
];
for (const [id, metadata, yaml] of presets) {
  const destination = join(template, '.agent-presets', id);
  mkdirSync(destination, { recursive: true });
  if (metadata) writeFileSync(join(destination, 'preset.yml'), metadata);
  else cpSync(join(source, 'preset.yml'), join(destination, 'preset.yml'));
  writeFileSync(join(destination, 'agent.cordis.yml'), yaml);
}
