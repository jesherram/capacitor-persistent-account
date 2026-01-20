package ee.forgr.capacitor_persistent_account;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.Context;
import org.json.JSONException;
import org.json.JSONObject;

class CapacitorPersistentAccount {

    static final String ACCOUNT_TYPE = "ee.forgr.capacitor_persistent_account";
    static final String DEFAULT_ACCOUNT_NAME = "CapacitorPersistentAccount";
    static final String USERDATA_JSON = "userdata_json";

    private final Context context;

    CapacitorPersistentAccount(Context context) {
        this.context = context.getApplicationContext();
    }

    void saveAccount(JSONObject data, String accountName) {
        AccountManager accountManager = AccountManager.get(context);
        Account[] existing = accountManager.getAccountsByType(ACCOUNT_TYPE);
        String effectiveAccountName = accountName != null && !accountName.isEmpty() ? accountName : DEFAULT_ACCOUNT_NAME;

        // Check if we need to rename the account or create a new one
        Account account;
        if (existing.length > 0) {
            Account currentAccount = existing[0];
            if (!currentAccount.name.equals(effectiveAccountName)) {
                // Account name changed, need to remove old and create new
                boolean removed = accountManager.removeAccountExplicitly(currentAccount);
                if (!removed) {
                    // If removal fails, continue using the current account to avoid data loss
                    account = currentAccount;
                } else {
                    account = new Account(effectiveAccountName, ACCOUNT_TYPE);
                    accountManager.addAccountExplicitly(account, null, null);
                }
            } else {
                account = currentAccount;
            }
        } else {
            account = new Account(effectiveAccountName, ACCOUNT_TYPE);
            accountManager.addAccountExplicitly(account, null, null);
        }
        accountManager.setUserData(account, USERDATA_JSON, data != null ? data.toString() : null);
    }

    AccountData readAccount() {
        AccountManager accountManager = AccountManager.get(context);
        Account[] existing = accountManager.getAccountsByType(ACCOUNT_TYPE);
        if (existing.length == 0) {
            return null;
        }
        Account account = existing[0];
        String raw = accountManager.getUserData(account, USERDATA_JSON);
        JSONObject data = null;
        if (raw != null && !raw.isEmpty()) {
            try {
                data = new JSONObject(raw);
            } catch (JSONException e) {
                data = null;
            }
        }
        return new AccountData(data, account.name);
    }

    static class AccountData {
        final JSONObject data;
        final String accountName;

        AccountData(JSONObject data, String accountName) {
            this.data = data;
            this.accountName = accountName;
        }
    }
}
