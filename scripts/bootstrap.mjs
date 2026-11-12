import { cpSync, existsSync, lstatSync, mkdirSync, mkdtempSync, readlinkSync, renameSync, rmSync, symlinkSync, unlinkSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, dirname, join, resolve } from 'node:path';

export function bootstrapPortable(app) {
  const home = resolve(process.env.DSH_PURGE_HOME || join(homedir(), '.dsh-purge-desktop-full'));
  if (!existsSync(home)) {
    mkdirSync(dirname(home), { recursive: true });
    const temp = mkdtempSync(join(dirname(home), `.${basename(home)}-`));
    try {
      cpSync(join(process.resourcesPath, 'profile-template'), temp, { recursive: true, verbatimSymlinks: true });
      writeFileSync(join(temp, '.dsh-purge-desktop-version'), '1\n');
      renameSync(temp, home);
    } finally {
      rmSync(temp, { recursive: true, force: true });
    }
  }
  if (!existsSync(join(home, '.dsh-purge-desktop-version'))) {
    throw new Error(`Refusing to use a data directory without the DSH Purge Desktop marker: ${home}`);
  }
  const toolsPath = join(home, 'tools');
  const bundledTools = join(process.resourcesPath, 'tools');
  try {
    const stat = lstatSync(toolsPath);
    if (!stat.isSymbolicLink()) throw new Error(`Expected tools to be a link: ${toolsPath}`);
    if (readlinkSync(toolsPath) !== bundledTools) unlinkSync(toolsPath);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  if (!existsSync(toolsPath)) symlinkSync(bundledTools, toolsPath, 'dir');
  const redteamDir = join(home, 'redteam');
  const redteamConfig = join(redteamDir, 'config.json');
  if (!existsSync(redteamConfig)) {
    mkdirSync(redteamDir, { recursive: true });
    writeFileSync(redteamConfig, JSON.stringify({
      version: 1,
      platform: 'auto',
      toolkitDir: join(toolsPath, 'redteam'),
      nucleiTemplatesDir: join(toolsPath, 'redteam', 'nuclei-templates'),
      binDirs: [],
      tools: {},
      env: { FOFA_KEY: '', REDTEAM_VPS_HOST: '', REDTEAM_VPS_KEY: '' },
      envAdaptSkip: false,
      envAdaptConfigured: true,
    }, null, 2) + '\n', { flag: 'wx', mode: 0o600 });
  }
  process.env.DSH_HOME = home;
  const userData = join(home, 'electron-user-data');
  mkdirSync(userData, { recursive: true });
  app.setPath('userData', userData);
}
