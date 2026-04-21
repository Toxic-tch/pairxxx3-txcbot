# Pterodactyl Wings - Render.com Deployment

## How to Deploy

### Step 1: Push to GitHub
Create a new GitHub repo and upload all files in this folder:
- Dockerfile
- render.yaml
- config.yml
- start.sh
- .dockerignore

### Step 2: Deploy to Render
1. Go to https://render.com
2. Sign up with GitHub
3. Click "New" -> "Blueprint"
4. Select your GitHub repo
5. Render will auto-detect render.yaml and deploy

### Step 3: Update Panel Node FQDN
Once deployed, Render gives you a URL like:
`https://pterodactyl-wings-xxxx.onrender.com`

On your Pterodactyl Panel:
1. Admin -> Nodes -> TOXICTECH -> Settings
2. Change FQDN to your Render URL
3. Go to Allocation tab -> Update IP/ports
4. Save

### Step 4: Verify
Go to Admin -> Nodes -> TOXICTECH
The node should show as "Active" with green status

## Files
- Dockerfile: Builds Wings + Docker inside Render
- config.yml: Wings configuration (pre-filled with your panel token)
- start.sh: Starts Docker daemon then Wings
- render.yaml: Render.com deployment config
