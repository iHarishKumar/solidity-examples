# **📌 The Solidity Playbook — Episode 2**

## **Role-Based Access Control with OpenZeppelin `AccessControl`**

---

## 🔍 What Are We Talking About Today?

In the last episode, we saw how **ownership** can be made safer using `Ownable2Step`.

But real-world smart contracts usually need **more than one privileged actor**.

Examples:

* An **admin** who can configure the system
* A **manager** who can perform day-to-day operations
* A **bot** that triggers automated actions

Trying to handle all of this with a single `owner` quickly becomes messy.

That’s where **`AccessControl`** comes in.

---

## 🤔 Why `AccessControl` Matters

Using a single owner for everything:

* Centralizes power
* Increases blast radius if the key is compromised
* Doesn’t scale well for teams or DAOs

`AccessControl` lets you:

* Define **multiple roles**
* Assign permissions **per role**
* Grant and revoke access dynamically

Think of it like **job titles** instead of one super-admin.

---

## 🧠 How `AccessControl` Works

At its core, `AccessControl` is based on **roles**, represented by `bytes32` identifiers.

Each role:

* Has a set of addresses assigned to it
* Can be checked using `onlyRole(ROLE_NAME)`
* Can have an **admin role** that controls who can grant or revoke it

The default admin for all roles is:

```solidity
DEFAULT_ADMIN_ROLE
```

⚠️ This role is extremely powerful — handle it with care.

---

## 💻 Solidity Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RoleBasedContract is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    uint256 public value;

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function setValue(uint256 _value) external onlyRole(MANAGER_ROLE) {
        value = _value;
    }

    function grantManager(address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _grantRole(MANAGER_ROLE, account);
    }
}
```

---

## 📍 Real-World Use Cases

• DeFi protocols with separate admin & operator roles
• DAOs assigning permissions to multisigs or bots
• Enterprise contracts with compliance separation
• Upgradeable contracts where only specific roles can upgrade

---

## 🛡 Security Considerations

• Protect `DEFAULT_ADMIN_ROLE` — losing it means losing control
• Avoid assigning admin roles to EOAs when a multisig can be used
• Keep role hierarchy simple
• Revoke unused roles proactively

Pro tip:
👉 Many exploits aren’t about bugs — they’re about **overpowered roles**.

---

## ⚡ Key Takeaways

✨ `Ownable` is great for simple contracts
✨ `AccessControl` is better for real-world systems
✨ Roles reduce risk by limiting who can do what
✨ Good role design = better security

---

## 🔗 Code & Tests

You can find the full working example **with test cases** in this repo:
👉 [https://github.com/iHarishKumar/solidity-examples](https://github.com/iHarishKumar/solidity-examples)

---

## 💬 What’s Next?

**Episode 3 options:**

* Upgradeable contracts & proxy admin roles
* Combining `Ownable2Step` + `AccessControl`
* Timelocks for sensitive operations
* Gas optimizations in access checks

Drop your pick in the comments 👇

---

**— The Solidity Playbook | Learn. Build. Ship.**
