import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const purgeDir = dirname(require.resolve('dsh-purge-community/package.json'));
const { readPresetDefinition } = await import(pathToFileURL(join(purgeDir, 'lib/redteam/preset-composition.js')));
const { adaptListAgents, migratePresetDefinition, registerPresetDefinitions } = await import(pathToFileURL(join(purgeDir, 'lib/preset-compat.js')));

export const name = 'dsh-portable-presets';
export const inject = [];

export function apply(ctx) {
  let releases = [];
  let stopped = false;
  let tries = 0;
  const register = async () => {
    if (stopped) return;
    let registry;
    try { registry = ctx.agentPresets || ctx.get?.('agentPresets'); } catch { /* not ready */ }
    if (!registry || typeof registry.register !== 'function') {
      if (tries++ < 40) setTimeout(register, 500);
      return;
    }
    for (const id of ['portable-reverse', 'portable-craft']) {
      try {
        const dir = join(process.env.DSH_HOME, '.agent-presets', id);
        const definition = adaptListAgents(readPresetDefinition(id, dir), ctx.get?.('profileContext')?.installAnchor);
        const migrated = migratePresetDefinition(definition, { stableChildIds: true });
        releases.push(await registerPresetDefinitions(registry, migrated.definitions));
      } catch (error) {
        ctx.logger?.warn?.('Could not register preset %s: %s', id, error.message);
      }
    }
    if (stopped) await Promise.all(releases.map(release => release()));
  };
  register();
  ctx.effect(() => async () => {
    stopped = true;
    await Promise.all(releases.map(release => release()));
    releases = [];
  }, 'dsh-portable-presets.registration');
}
