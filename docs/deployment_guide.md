# Deployment Guide

Step by step for getting both dashboards live and linkable, to paste into the README's Links section.

## Part 1: Streamlit Community Cloud (free, no local install needed)

1. Push this project to a GitHub repo, public or private (public is required for the free tier).
   Make sure app.py, requirements.txt, and cleaned_data/state_delivery_satisfaction_revenue.csv are all in the repo. cleaned_data/olist.db and raw_data are excluded by .gitignore, app.py does not need them.

2. Go to https://share.streamlit.io and sign in with your GitHub account.

3. Click "New app".

4. Fill in:
   - Repository: pick this repo from the dropdown
   - Branch: main (or whichever branch you pushed to)
   - Main file path: app.py

5. Click "Deploy". First deploy takes 2 to 5 minutes while it installs requirements.txt.

6. Once live, you'll get a URL like:
   https://yourusername-olist-ecommerce-analysis.streamlit.app

7. Copy that URL into README.md, replacing the "[add Streamlit Community Cloud link after deploying]" placeholder in the Links section.

### If the deploy fails
- Check the app logs in the Streamlit Cloud dashboard, most failures are a missing package (check requirements.txt) or a wrong file path to the csv (app.py expects to run from the repo root, so cleaned_data/state_delivery_satisfaction_revenue.csv must exist at that path in the repo).

## Part 2: Power BI publish to web

Do this after building the report using docs/power_bi_build_guide.md.

1. In Power BI Desktop, with the report open, go to File, then Publish, then "Publish to Power BI". This needs a free Power BI account (app.powerbi.com), sign in if prompted.

2. Choose a workspace to publish to (your personal "My workspace" is fine for a portfolio piece).

3. Once published, Power BI Desktop shows a "Success" dialog with a link, or go to https://app.powerbi.com, open the workspace, and open the report there.

4. In the Power BI service (the website, not the desktop app), open the report and go to File, then "Embed report", then "Publish to web (public)".

5. A warning appears explaining this makes the report visible to anyone with the link, with no login required. Confirm you're fine with that, since this data is already public (Olist's dataset is open on Kaggle), then click "Create embed code".

6. Copy the direct link (not just the iframe code) from the popup. That's the one to paste into the README, replacing the "[add publish-to-web link after building from docs/power_bi_build_guide.md]" placeholder.

### If "Publish to web" is greyed out or missing
Some organization Power BI tenants disable public web publishing. If that happens with a work or school account, sign in with a free personal Microsoft account instead (app.powerbi.com supports both), since personal accounts default to allowing it.

## After both are live

Update README.md's Links section with both real URLs, then update docs/linkedin_post_draft.md the same way before posting.
