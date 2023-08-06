# Miscellaneous

These files contain important data sourced by the configuration, or simply
information to store for safekeeping later.

---

Creating hashed password for [password.sha512](./password.sha512):

```
mkpasswd -m sha-512
```

---

Getting key for [public-keys](./public-keys):

```
ssh-keyscan -t ed25519 <hostname>
```

