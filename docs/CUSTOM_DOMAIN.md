# Custom Domain & Web Deployment

Track Pe's production web app is served at:

```
https://track-pe.itisuniqueofficial.com/
```

Deployment is automated by `.github/workflows/web-deploy.yml` using the GitHub
Actions Pages flow:

```
flutter build web --release --base-href "/"
        ↓
build/web  (includes web/CNAME → track-pe.itisuniqueofficial.com)
        ↓
actions/upload-pages-artifact
        ↓
actions/deploy-pages → GitHub Pages → custom domain
```

## What is already configured in the repo

- `web/CNAME` contains the domain only: `track-pe.itisuniqueofficial.com`
  (no scheme, no path, no trailing slash). Flutter copies it into `build/web`.
- `--base-href "/"` so routes, assets, `manifest.json`, `favicon.png`, icons,
  JS/CSS, and the service worker resolve from the domain root.

## Owner actions required (NOT done automatically)

These steps happen outside the repository and must be performed by the owner.
The exact GitHub Pages hostname must be read from the repository's actual Pages
settings — **do not guess it**.

1. **DNS** — at the DNS provider for `itisuniqueofficial.com`, add:

   ```
   Type:   CNAME
   Name:   track-pe
   Target: <the GitHub Pages hostname shown in this repo's Pages settings>
           (for an organization/user site this is typically
            <owner>.github.io — point to the Pages host, excluding the repo name)
   ```

2. **GitHub Pages settings** — in the repository: Settings → Pages →
   Source: **GitHub Actions**, and set the **Custom domain** to
   `track-pe.itisuniqueofficial.com`. Committing `web/CNAME` alone does not
   register the custom domain; the Pages setting/API must also be configured.

3. **HTTPS** — after DNS resolves and GitHub verifies the domain, wait for the
   certificate to be provisioned, then enable **Enforce HTTPS**.

4. **Verify** — load `https://track-pe.itisuniqueofficial.com/` and confirm
   routes, assets, manifest, favicon, icons, and the service worker load, and
   that HTTPS is active.

> HTTPS/certificate provisioning can take time after DNS changes. Do not treat
> HTTPS as active until it has been verified in the browser.
