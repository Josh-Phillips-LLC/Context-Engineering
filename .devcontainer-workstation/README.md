# Devcontainer Workstation Setup

This workflow builds the container from scratch outside VS Code, then attaches VS Code to the running container.

## 1) Build and start from host

Run these from your host machine terminal (not inside a container):

```bash
cd /path/to/Context-Engineering/.devcontainer-workstation
docker compose down
docker compose up -d --build
```

Use this only if you want a full reset of persisted container data:

```bash
docker compose down -v
docker compose up -d --build
```

Confirm container is running:

```bash
docker ps --filter name=agent-workstation
```

## 2) Create/clone repos in container-owned storage

The repo root inside the container is `/workspace/Projects` (Docker volume-backed).

```bash
docker exec -it agent-workstation bash
cd /workspace/Projects
git clone https://github.com/joshphillipssr/Context-Engineering.git
exit
```

## 3) Verify SSH agent forwarding (for signed commits)

```bash
docker exec -it agent-workstation bash -lc 'echo $SSH_AUTH_SOCK && ssh-add -l'
```

Expected: `SSH_AUTH_SOCK` is set and `ssh-add -l` lists identities.

## 4) Attach VS Code to running container

In local (non-containerized) VS Code:

1. Open Command Palette
2. Run `Dev Containers: Attach to Running Container...`
3. Select `agent-workstation`
4. Open folder `/workspace/Projects/Context-Engineering`

## 5) Optional signing test inside attached terminal

```bash
git commit -S --allow-empty -m "signing test"
```
