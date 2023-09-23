import React from "react";

function AccountButton({account, selectAccount, selectedAccount, theme}) {
    return (
        <div className={`w-24 text-sm font-bold border rounded h-8 cursor-pointer flex justify-center items-center m-2 ${theme}-border-1 ${theme}-c1 ${selectedAccount === account.id ? `${theme}-bg2 ${theme}-c2` : ''}`}
        onClick={()=>selectAccount(account.id)}>
            {account.name}
        </div>
    );
    
}

export default AccountButton