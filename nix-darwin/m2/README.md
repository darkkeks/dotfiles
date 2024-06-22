1. Generate random master-password:
    ```shell
    dd if=/dev/urandom bs=1 count=128 2>/dev/null | base64 --wrap=0
    ```
1. Encrypt it (this step does not make any sense - it is reversible without the knowledge of password):
    ```shell
    mvn --encrypt-master-password
    ```
1. Create `settings-security.xml`:
    ```xml
    <settingsSecurity>
        <master>encrypted master-password here</master>
    </settingsSecurity>
    ```
1. Deploy this file as a secret.
