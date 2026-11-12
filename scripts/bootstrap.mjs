import { cpSync, existsSync, mkdirSync, mkdtempSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, dirname, join, resolve } from 'node:path';

export function bootstrapPortable(app) {
  const home = resolve(process.env.DSH_PURGE_HOME || join(homedir(), '.dsh-purge-desktop'));
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
  process.env.DSH_HOME = home;
  const userData = join(home, 'electron-user-data');
  mkdirSync(userData, { recursive: true });
  app.setPath('userData', userData);
}
