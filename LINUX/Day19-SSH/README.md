# Day 19 — SSH: Secure Shell Deep Dive

Today was about the most important tool in DevOps: SSH.
It's how you access servers, transfer files, and stay secure.
Everything you do remotely goes through SSH.

---

## What Is SSH

SSH = Secure Shell. A secure tunnel to a remote server.

```
Without SSH:          With SSH:
unencrypted ❌       encrypted ✓
passwords leak ❌    passwords safe ✓
hacker sees all ❌   hacker sees nothing ✓
```

SSH encrypts everything end-to-end. Industry standard.

---

## Basic SSH Connection

```bash
# connect to server
ssh username@hostname

# examples
ssh anand@192.168.1.10
ssh anand@server.example.com

# specific port
ssh -p 2222 anand@server.com

# run command without opening shell
ssh anand@server.com "ls /var/www"

# exit
exit
```

---

## SSH Keys (Better Than Passwords)

### Generate Keys

```bash
# generate key pair
ssh-keygen -t ed25519 -C "anand@macbook"

# creates:
# ~/.ssh/id_ed25519      (private — SECRET!)
# ~/.ssh/id_ed25519.pub  (public — goes on servers)
```

### Copy Key to Server

```bash
# automatic way
ssh-copy-id -i ~/.ssh/id_ed25519.pub anand@server.com

# asks for password once
# then copies your public key
# now you log in without password!

# manual way
# add contents of ~/.ssh/id_ed25519.pub to:
# ~/.ssh/authorized_keys on server
```

### Key Security

```bash
# permissions matter!
chmod 600 ~/.ssh/id_ed25519      # private key
chmod 644 ~/.ssh/id_ed25519.pub  # public key

# NEVER:
# ❌ share private key
# ❌ commit to git
# ❌ post online

# Check key fingerprint
ssh-keygen -l -f ~/.ssh/id_ed25519
# gives you a hash to verify this is your key
```

---

## SSH Config File (Shortcuts)

Create `~/.ssh/config`:

```
Host prod
    HostName prod.example.com
    User deploy
    Port 22
    IdentityFile ~/.ssh/id_ed25519

Host dev
    HostName dev.example.com
    User dev
    IdentityFile ~/.ssh/id_ed25519
```

Now use shortcuts:
```bash
ssh prod        # instead of ssh -p 22 deploy@prod.example.com
ssh dev         # instead of ssh -p 22 dev@dev.example.com
```

### SSH Config Options

```bash
Host name
    HostName actual.hostname.com
    User username
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    
    # keep connection alive
    ServerAliveInterval 60
    ServerAliveCountMax 10
    
    # compression for slow networks
    Compression yes
    
    # auto add to agent
    AddKeysToAgent yes
```

---

## SCP (Secure Copy)

Copy files over SSH.

```bash
# copy TO server
scp myfile.txt anand@server.com:/home/anand/

# copy FROM server
scp anand@server.com:/var/log/app.log .

# copy folder
scp -r folder/ anand@server.com:/home/anand/

# with SSH config shortcut
scp myfile.txt prod:/home/deploy/

# specify port
scp -P 2222 myfile.txt anand@server.com:/tmp/
# note: -P not -p for scp
```

---

## SSH Tunneling (Port Forwarding)

Access remote services through SSH tunnel.

### Local Tunnel (Access Remote Service Locally)

```bash
# forward remote port to local
ssh -L 5432:localhost:5432 anand@db-server.com

# now connect locally
psql -h localhost -U postgres
# it connects through tunnel to db-server!
```

Example: Access remote database from laptop

```bash
# Terminal 1: create tunnel
ssh -L 5432:localhost:5432 anand@db.example.com
# leave running

# Terminal 2: connect to local port
psql -h localhost -U postgres
# connected to remote database!
```

### Remote Tunnel (Expose Local to Remote)

```bash
# expose local service to remote
ssh -R 8080:localhost:3000 anand@server.com

# now server can access:
# http://localhost:8080
# which routes to your local:3000
```

---

## Rsync Over SSH

Powerful file sync over SSH.

```bash
# sync to server
rsync -avz local-folder/ user@server:/remote/path/

# pull from server
rsync -avz user@server:/remote/ /local/

# with delete (make remote match local exactly)
rsync -avz --delete local/ user@server:/remote/

# using SSH config shortcut
rsync -avz local/ prod:/remote/

# useful flags:
# -a = archive (preserve permissions, timestamps)
# -v = verbose
# -z = compress
# --delete = delete files on destination not on source
```

---

## Real Scenarios

### Scenario 1 — Access Restricted Database

Database only accepts connections from localhost.
You want to query from your laptop.

```bash
# create tunnel
ssh -L 5432:localhost:5432 user@db-server.com

# in another terminal
psql -h localhost
# works!
```

### Scenario 2 — Backup Server Files

```bash
#!/bin/bash
BACKUP_DIR="$HOME/backups"

rsync -avz --delete \
    prod-server:/var/www/code \
    prod-server:/etc/nginx \
    "$BACKUP_DIR/"

echo "Backup complete"
```

### Scenario 3 — Deploy Code

```bash
#!/bin/bash
# build locally
npm run build

# sync to server
rsync -avz build/ prod:/var/www/app/public/

# restart
ssh prod "sudo systemctl restart nginx"
```

### Scenario 4 — Monitor Remote Server

```bash
while true; do
    ssh prod "df -h /"
    ssh prod "free -h"
    ssh prod "systemctl status myapp"
    sleep 60
done
```

---

## Challenges Done

### Challenge 1 — Basic SSH
Connected to a server, ran commands, exited.

### Challenge 2 — SSH Keys
Generated key pair, copied to server, logged in without password.

### Challenge 3 — SSH Config
Created config file with shortcuts, tested them.

### Challenge 4 — SCP
Copied files to and from server.

### Challenge 5 — Port Forwarding
Created tunnel, accessed remote service locally.

### Challenge 6 — Rsync Over SSH
Synced folders, pulled from server, used --delete.

---

## SSH Security Best Practices

```bash
# ✓ Generate strong key
ssh-keygen -t ed25519

# ✓ Protect private key
chmod 600 ~/.ssh/id_ed25519

# ✓ Use SSH config for management
# keep all hosts and settings organized

# ✓ Use key-based auth, not passwords
# disable password auth on servers

# ✓ Use different keys for different environments
id_ed25519          # general use
id_rsa_prod         # production only
id_rsa_deploy       # deployment bot

# ✓ Rotate keys regularly
# generate new ones every 6-12 months

# ✗ Never put private key on servers
# ✗ Never share private key
# ✗ Never commit keys to git
```

---

## SSH Connection Troubleshooting

```bash
# debug connection
ssh -vvv prod 2>&1 | head -30
# -vvv = very verbose, shows every step

# test specific port
ssh -p 2222 prod -v

# test specific key
ssh -i ~/.ssh/id_custom prod -v

# check if key added to agent
ssh-add -l
# shows all keys agent knows about

# add key to agent
ssh-add ~/.ssh/id_ed25519

# permission issues
# private key must be 600
# ~/.ssh must be 700
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519*

# known hosts issues
# remove server from known_hosts
ssh-keygen -R server.example.com

# force specific auth method
ssh -o PubkeyAuthentication=no user@server
# (forces password)
```

---

## SSH vs SCP vs Rsync

| Tool | Use For | Speed | Features |
|------|---------|-------|----------|
| SSH | interactive shell | - | full control |
| SCP | copy individual files | ok | simple |
| Rsync | sync large folders | fast | only copies changes |

For backups: use rsync.
For single files: use scp.
For interactive work: use ssh.

---

## Advanced SSH Tricks

### SSH Agent (remember passphrases)

```bash
# start agent
eval "$(ssh-agent -s)"

# add key
ssh-add ~/.ssh/id_ed25519

# now doesn't ask for passphrase

# list keys in agent
ssh-add -l

# remove key from agent
ssh-add -d ~/.ssh/id_ed25519
```

### Jump Host (SSH through bastion)

```bash
Host prod
    HostName prod.internal.example.com
    User deploy
    ProxyJump bastion
    # connects to bastion first, then to prod
    
Host bastion
    HostName bastion.example.com
    User bastion-user
```

Now: `ssh prod` connects through bastion automatically.

### Parallel SSH (run on multiple servers)

```bash
#!/bin/bash
for server in prod staging dev; do
    ssh "$server" "uptime" &
done
wait
# runs on all 3 servers in parallel
```

---

## Things That Clicked

- SSH encrypts everything end-to-end
- Keys are more secure than passwords
- SSH config file saves endless typing
- Tunneling lets you access restricted services safely
- Rsync is the backup tool of choice for DevOps
- Private key permissions are critical (600, not 644)
- SSH agent remembers passphrases so you don't type them
- Known_hosts protects against man-in-the-middle attacks
- Different keys for different purposes (prod, dev, deploy)

---

## Production Checklist

When setting up SSH for production:

```bash
☐ Generate ed25519 keys (not RSA)
☐ Private key permissions 600
☐ Public key in ~/.ssh/authorized_keys
☐ SSH config file organized by environment
☐ Test with -v flag before production use
☐ Disable password auth: PasswordAuthentication no
☐ Use different keys for different systems
☐ Keep private keys off servers
☐ Add known_hosts entries
☐ Document which keys go where
☐ Monitor /var/log/auth.log for ssh attempts
```

---

## Real DevOps Workflow

```bash
# 1. Generate keys
ssh-keygen -t ed25519 -C "deploy@$(date +%Y%m%d)"

# 2. Add to servers
ssh-copy-id -i ~/.ssh/id_ed25519.pub anand@prod

# 3. Create SSH config
nano ~/.ssh/config
# add all servers

# 4. Test connections
ssh prod
ssh staging
ssh dev

# 5. Setup backups
# cronjob running rsync over SSH
0 2 * * * rsync -avz --delete prod:/code ~/backups/prod-code

# 6. Deploy automatically
# cd code, git push, rsync to server, restart service
```
