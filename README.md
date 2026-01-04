# Calor Legal Documents - GitHub Pages Setup

This directory contains the Privacy Policy and Terms of Service for the Calor app, ready to be hosted on GitHub Pages.

## Files

- `index.html` - Landing page with links to legal documents
- `privacy.html` - Privacy Policy
- `terms.html` - Terms of Service

## Setup Instructions

### Option 1: Host on GitHub Pages (Recommended - Free & Easy)

1. **Create a new GitHub repository** (or use existing xcalor repo):
   ```bash
   # If creating new repo
   gh repo create calor-legal --public

   # Or use existing repo
   cd /Users/salem/Documents/Programming/xcalor
   ```

2. **Push the docs folder to GitHub**:
   ```bash
   cd /Users/salem/Documents/Programming/xcalor

   # If not already a git repo
   git init
   git add docs/
   git commit -m "Add legal documents for GitHub Pages"

   # Add remote (replace USERNAME with your GitHub username)
   git remote add origin https://github.com/USERNAME/calor-legal.git
   git branch -M main
   git push -u origin main
   ```

3. **Enable GitHub Pages**:
   - Go to your repo on GitHub: `https://github.com/USERNAME/calor-legal`
   - Click **Settings** → **Pages**
   - Under **Source**, select **Deploy from a branch**
   - Select branch: **main**
   - Select folder: **/docs**
   - Click **Save**

4. **Wait 1-2 minutes**, then visit:
   - Privacy Policy: `https://USERNAME.github.io/calor-legal/privacy.html`
   - Terms of Service: `https://USERNAME.github.io/calor-legal/terms.html`

5. **Update Constants.swift** with your actual URLs:
   ```swift
   enum URLs {
       static var privacyPolicy: URL {
           URL(string: "https://USERNAME.github.io/calor-legal/privacy")!
       }

       static var termsOfService: URL {
           URL(string: "https://USERNAME.github.io/calor-legal/terms")!
       }
   }
   ```

   Replace `USERNAME` with your actual GitHub username.

### Option 2: Custom Domain (Professional)

If you want a custom domain like `calor.app` or `legal.calor.app`:

1. **Buy a domain** from:
   - Namecheap (~$10/year)
   - Google Domains (~$12/year)
   - Cloudflare (~$10/year)

2. **Host on Vercel or Netlify** (both free):

   **Vercel:**
   ```bash
   cd /Users/salem/Documents/Programming/xcalor/docs
   npx vercel deploy --prod
   ```

   **Netlify:**
   ```bash
   cd /Users/salem/Documents/Programming/xcalor/docs
   npx netlify deploy --prod --dir .
   ```

3. **Connect custom domain** in Vercel/Netlify dashboard

4. **Update Constants.swift**:
   ```swift
   enum URLs {
       static var privacyPolicy: URL {
           URL(string: "https://calor.app/privacy")!
       }

       static var termsOfService: URL {
           URL(string: "https://calor.app/terms")!
       }
   }
   ```

### Option 3: Use GitHub Pages with Custom Domain

1. Follow Option 1 steps 1-4
2. In GitHub repo → Settings → Pages → Custom domain
3. Enter your domain (e.g., `legal.calor.app`)
4. Add CNAME record in your domain DNS settings:
   - Type: `CNAME`
   - Name: `legal` (or `@` for root domain)
   - Value: `USERNAME.github.io`

## Important Notes

1. **Update email addresses** in HTML files:
   - Replace `privacy@calor.app` with your actual email
   - Replace `support@calor.app` with your actual email
   - Replace `dpo@calor.app` with your actual email (if you have a Data Protection Officer)

2. **Update free scan limit**:
   - Currently shows "4 per day" in terms.html
   - Make sure this matches your actual limit in the app

3. **Legal review**:
   - Have a lawyer review these documents for your specific situation
   - Especially important for the arbitration clause and health disclaimers

4. **Keep documents accessible**:
   - App Store requires privacy policy to be publicly accessible
   - Do not password-protect or hide behind login

## Testing

After hosting, test the URLs:
```bash
curl -I https://USERNAME.github.io/calor-legal/privacy.html
curl -I https://USERNAME.github.io/calor-legal/terms.html
```

Both should return `200 OK`.

## Updating Documents

To update the documents after initial hosting:

1. Edit the HTML files locally
2. Commit and push changes:
   ```bash
   cd /Users/salem/Documents/Programming/xcalor
   git add docs/
   git commit -m "Update privacy policy"
   git push
   ```
3. Changes will appear on GitHub Pages within 1-2 minutes

## Troubleshooting

**Issue**: GitHub Pages not showing up
- **Solution**: Wait 2-5 minutes for initial deployment
- Check Settings → Pages for build status

**Issue**: 404 errors
- **Solution**: Make sure folder is `/docs` not `/doc`
- Ensure files are named exactly `privacy.html` and `terms.html`

**Issue**: App Store rejection for broken links
- **Solution**: Test URLs in a browser before submission
- Use `curl` to verify they return 200 OK

## Next Steps

After hosting:

1. ✅ Update `Calor/Core/Constants.swift` with real URLs
2. ✅ Update App Store Connect with privacy policy URL
3. ✅ Test URLs in Safari on iOS device
4. ✅ Rebuild and test the app
