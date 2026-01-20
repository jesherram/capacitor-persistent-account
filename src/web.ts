import { WebPlugin } from '@capacitor/core';

import type { CapacitorPersistentAccountPlugin } from './definitions';

const WEB_STORAGE_KEY = 'capacitor_persistent_account';
const WEB_STORAGE_ACCOUNT_NAME_KEY = 'capacitor_persistent_account_name';

export class CapacitorPersistentAccountWeb extends WebPlugin implements CapacitorPersistentAccountPlugin {
  async readAccount(): Promise<{ data: unknown | null; accountName: string | null }> {
    try {
      const raw = localStorage.getItem(WEB_STORAGE_KEY);
      const accountName = localStorage.getItem(WEB_STORAGE_ACCOUNT_NAME_KEY);
      return { data: raw ? JSON.parse(raw) : null, accountName: accountName ?? null };
    } catch (err) {
      return { data: null, accountName: null };
    }
  }

  async saveAccount(options: { data: unknown; accountName?: string }): Promise<void> {
    try {
      localStorage.setItem(WEB_STORAGE_KEY, JSON.stringify(options?.data ?? null));
      if (options?.accountName != null) {
        localStorage.setItem(WEB_STORAGE_ACCOUNT_NAME_KEY, options.accountName);
      }
    } catch (err) {
      // ignore
    }
  }

  async getPluginVersion(): Promise<{ version: string }> {
    return { version: 'web' };
  }
}
