# Backend Configuration Guide

## Configuration Files

### appsettings.json (NOT in Git)
Main configuration file containing sensitive information like database passwords and JWT keys.
- **Location:** `src/backend/appsettings.json`
- **Status:** ❌ NOT committed to git (in .gitignore)
- **How to create:** Copy from `appsettings.Example.json` and update with your local settings

### appsettings.Development.json (In Git)
Development-specific configuration with placeholders.
- **Location:** `src/backend/appsettings.Development.json`
- **Status:** ✅ Committed to git (safe - uses placeholders)
- **Note:** Replace `YOUR_PASSWORD` with your actual PostgreSQL password locally in `appsettings.json`

### appsettings.Example.json (In Git)
Example/template configuration file for reference.
- **Location:** `src/backend/appsettings.Example.json`
- **Status:** ✅ Committed to git (safe - example only)
- **Purpose:** Template for new developers to create their own `appsettings.json`

## Setup Instructions

1. Copy the example file:
   ```bash
   cp appsettings.Example.json appsettings.json
   ```

2. Edit `appsettings.json` and replace:
   - `YOUR_PASSWORD` with your PostgreSQL password
   - `YOUR_JWT_SECRET_KEY` with a secure JWT key (if needed)

3. **Never commit `appsettings.json` to git!**

## Security Notes

⚠️ **IMPORTANT:**
- `appsettings.json` is ignored by git to protect sensitive data
- Always use environment variables in production
- Never hardcode real passwords in files that are committed to git
- The `.gitignore` file already includes `appsettings.json`

## Environment Variables (Production)

For production deployments, use environment variables instead of appsettings.json:

```bash
export ConnectionStrings__eUITDatabase="Server=prod-server;Port=5432;Database=eUIT;User Id=prod_user;Password=secure_password;"
export Jwt__Key="production_jwt_secret_key"
```

Or use Azure App Service Configuration, AWS Secrets Manager, or similar services.
