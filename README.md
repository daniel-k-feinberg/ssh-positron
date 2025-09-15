# Docker container environment for SSH access via mapped folder

Container for connecting Positron via SSH and mapping local folder.

## SSH Access to Dev Container

This project exposes an OpenSSH server inside the dev container so external tools (e.g. Positron / RStudio / other IDEs) can attach.

### Summary

-   Host machine exposes container port 22 at localhost:2222
-   User inside container: `rstudio`
-   Authentication: your local public key mounted as `authorized_keys`
-   Your key: `~/.ssh/id_ed25519.pub` (public) with matching private key `~/.ssh/id_ed25519`

## To Regenerate keys

Enter into terminal at mapped folder:

``` bash
ssh-keygen -R "[127.0.0.1]:2222"
```

Then run:

``` bash
ssh positron-docker
```

You will be prompted to accept the new host key. Type `yes` and press Enter to connect.

### Recommended \~/.ssh/config Entry

Add (or replace) this block in `~/.ssh/config`:

```
Host positron-docker
    HostName 127.0.0.1
    Port 2222
    User rstudio
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
    UseKeychain yes    # macOS specific
    IdentitiesOnly yes
```

Then connect with:

```
ssh positron-docker
```

Or explicitly:

```
ssh -p 2222 rstudio@localhost
```

## First-Time (Re)build

If you changed the Dockerfile or docker-compose.yml file:

```
docker compose -f ./docker-compose.yml build
```

Then start:

```
docker compose -f ./docker-compose.yml up -d
```

## Verifying SSHD

```
docker compose -f ./docker-compose.yml ps
ssh positron-docker 'whoami && hostname && ls -ld ~/.ssh'
```

If connection fails, get logs:

```
docker logs positron-ds-env | tail -n 80
```

Check auth log:

```
docker compose -f ./docker-compose.yml exec tidyverse bash -c 'tail -n 80 /var/log/auth.log'
```

## Regenerating Keys (optional)

If you need a new key pair:

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "dev container access"
```

Then rebuild/restart so the updated public key mounts in.

## Troubleshooting Matrix

| Symptom | Likely Cause | Fix |
|-------------------------|-------------------|----------------------------|
| Could not resolve hostname positron-docker | Missing HostName entry | Add HostName 127.0.0.1 to ssh config |
| Connection refused | Container not running / port not published | Start container, check ports mapping |
| Permission denied (publickey) | Wrong key or permissions | Ensure IdentityFile matches mounted public key; private key 600 |
| Instant disconnect / reset | sshd not started / crashed | View container logs; rebuild |
| Works with `ssh -p 2222 rstudio@localhost` but not alias | Bad \~/.ssh/config precedence | Check for duplicate Host blocks earlier in file |

## Security Notes

-   No password auth; only keys.
-   Port is bound only to localhost by default; if you run Docker differently, verify with `lsof -nP -iTCP:2222`.
-   Rotate keys if sharing workstation.

### If I delete or rebuild the container

This is a security feature of SSH: Your computer stores a unique cryptographic "fingerprint" (a host key) for every server it connects to in the file `~/.ssh/known_hosts`.

Every time you completely rebuild your Docker container, the SSH server inside it generates a *brand new, unique* host key.

Your SSH client sees that the server at `[localhost]:2222` is now presenting a *different* key than the one it has on record from your last connection. It correctly warns you that the host's identity has changed, which could indicate a man-in-the-middle attack. In your case, however, it's simply because you've replaced the old container with a new one.

### The Solution

You need to remove the old, "offending" host key from your `known_hosts` file. The easiest and safest way to do this is with the `ssh-keygen` command.

1.  **Run the following command in your terminal:** This command will automatically find and remove the old key for `[localhost]:2222`.

    ``` bash
    ssh-keygen -R "[localhost]:2222"
    ```

2.  **Connect Again:** Now, try to connect to the container as you did before.

    ``` bash
    ssh -p 2222 rstudio@localhost
    ```

3.  **Accept the New Key:** This time, because your computer has no stored key for this host, it will prompt you to verify the new connection. It will look something like this:

    ```
    The authenticity of host '[localhost]:2222 (127.0.0.1)' can't be established.
    ED25519 key fingerprint is SHA256:JRyCYdgnUXnq3/SBcowhlkgKA7WhfcQxbrKq4YU2COg.
    Are you sure you want to continue connecting (yes/no/[fingerprint])?
    ```

    Type **`yes`** and press Enter. Your computer will save the new key, and you will be successfully logged into your container.

You will need to repeat this process of removing the old key each time you run `docker compose build` and recreate the container from scratch.

## To shut down and rebuild container without cache

``` bash
docker compose -f ./docker-compose.yml down -v

docker compose -f ./docker-compose.yml build --no-cache

docker compose -f ./docker-compose.yml up -d

docker logs positron-ds-env
```

## Acknowledgements

Many thanks to the following folks:

-   [Andrew Heiss](https://github.com/andrewheiss) for the [excellent guide for connecting Positron to Docker images via SSH](https://www.andrewheiss.com/blog/2025/07/05/positron-ssh-docker/)

-   [The Rocker Project Team](https://www.rocker-project.org/) for the [Rocker](https://hub.docker.com/u/rocker) Docker images

-   [Posit](https://posit.org/) for the very delightful [Positron IDE](https://positron.posit.co/)

-   [Docker](https://www.docker.com/) for the [Docker](https://hub.docker.com/) container platform that makes this workflow possible

-   My Gen-AI buddies, Claude, GPT-5, and Gemini, for their very helpful explanations and code completions 🤖

I would also like to acknowledge the contributions of the many open source maintainers and developers whose work went into creating the powerful open source tools that allow this workflow to exist. There are too many of you to name, and that is the coolest part 🙂 My heartfelt thanks to all of you.
